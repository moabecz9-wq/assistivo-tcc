import 'dart:ui';

enum Zona { esquerda, centro, direita }

enum Orientacao { desviarEsquerda, desviarDireita, livre, parar }

class Obstaculo {
  final String classe;
  final double confianca;
  final Rect caixa; // coordenadas normalizadas (0 a 1)

  const Obstaculo({
    required this.classe,
    required this.confianca,
    required this.caixa,
  });

  double get area => caixa.width * caixa.height;

  /// Piso tátil é guia de caminho, não obstáculo.
  bool get ehGuia => classe == 'piso tátil';

  Zona get zona {
    final cx = caixa.center.dx;
    if (cx < 1 / 3) return Zona.esquerda;
    if (cx > 2 / 3) return Zona.direita;
    return Zona.centro;
  }
}

class Decisao {
  final Orientacao orientacao;
  final Set<Zona> bloqueadas;
  final Obstaculo? principal; // só obstáculos
  final Obstaculo? guia; // piso tátil

  const Decisao(this.orientacao, this.bloqueadas, this.principal, this.guia);

  String get chave {
    switch (orientacao) {
      case Orientacao.desviarEsquerda:
        return 'esquerda';
      case Orientacao.desviarDireita:
        return 'direita';
      case Orientacao.livre:
        return 'livre';
      case Orientacao.parar:
        return 'parar';
    }
  }

  String get _avisoGuia {
    final g = guia;
    if (g == null) return '';
    switch (g.zona) {
      case Zona.esquerda:
        return ', piso tátil à esquerda';
      case Zona.direita:
        return ', piso tátil à direita';
      case Zona.centro:
        return ', piso tátil à frente';
    }
  }

  String get mensagem {
    final nome = principal?.classe ?? 'obstáculo';
    switch (orientacao) {
      case Orientacao.desviarEsquerda:
        return '$nome à frente, desvie pela esquerda';
      case Orientacao.desviarDireita:
        return '$nome à frente, desvie pela direita';
      case Orientacao.parar:
        return '$nome à frente, pare';
      case Orientacao.livre:
        return 'caminho livre, siga em frente$_avisoGuia';
    }
  }
}

class NavigationLogic {
  static const double confiancaMinima = 0.5;
  static const double areaMinima = 0.02;
  static const double sobreposicaoMinima = 0.2;

  static String traduzirClasse(String nome) {
    final n = nome.toLowerCase();
    if (n == 'person' || n == 'pessoa') return 'pessoa';
    if (n.contains('stair') || n.contains('escada')) return 'escada';
    if (n.contains('tactile') ||
        n.contains('tatil') ||
        n.contains('tátil') ||
        n.contains('braille') ||
        n.contains('paving')) {
      return 'piso tátil';
    }
    return 'objeto';
  }

  static bool _ocupa(Rect caixa, Zona zona) {
    const limites = {
      Zona.esquerda: [0.0, 1 / 3],
      Zona.centro: [1 / 3, 2 / 3],
      Zona.direita: [2 / 3, 1.0],
    };
    final ini = limites[zona]![0];
    final fim = limites[zona]![1];
    final inicio = caixa.left > ini ? caixa.left : ini;
    final termino = caixa.right < fim ? caixa.right : fim;
    final sobreposicao = termino - inicio;
    return sobreposicao > 0 && sobreposicao / (fim - ini) >= sobreposicaoMinima;
  }

  static Obstaculo? _maior(Iterable<Obstaculo> lista) {
    Obstaculo? m;
    for (final o in lista) {
      if (m == null || o.area > m.area) m = o;
    }
    return m;
  }

  static Decisao decidir(List<Obstaculo> deteccoes) {
    final validos = deteccoes
        .where((o) => o.confianca >= confiancaMinima && o.area >= areaMinima)
        .toList();
    final obstaculos = validos.where((o) => !o.ehGuia).toList();
    final guias = validos.where((o) => o.ehGuia);

    final bloqueadas = <Zona>{};
    for (final o in obstaculos) {
      for (final z in Zona.values) {
        if (_ocupa(o.caixa, z)) bloqueadas.add(z);
      }
    }

    Orientacao orientacao;
    if (!bloqueadas.contains(Zona.centro)) {
      orientacao = Orientacao.livre;
    } else if (!bloqueadas.contains(Zona.esquerda)) {
      orientacao = Orientacao.desviarEsquerda;
    } else if (!bloqueadas.contains(Zona.direita)) {
      orientacao = Orientacao.desviarDireita;
    } else {
      orientacao = Orientacao.parar;
    }
    return Decisao(orientacao, bloqueadas, _maior(obstaculos), _maior(guias));
  }
}
