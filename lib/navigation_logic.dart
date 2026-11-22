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
  final Obstaculo? principal;

  const Decisao(this.orientacao, this.bloqueadas, this.principal);

  /// Chave usada no registro CSV.
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
        return 'caminho livre, siga em frente';
    }
  }
}

class NavigationLogic {
  static const double confiancaMinima = 0.5;
  static const double areaMinima = 0.02; // ignora objetos muito distantes
  static const double sobreposicaoMinima = 0.2; // fração da zona ocupada

  /// Pessoa -> "pessoa", escada -> "escada", qualquer outra coisa -> "objeto".
  static String traduzirClasse(String nome) {
    final n = nome.toLowerCase();
    if (n == 'person') return 'pessoa';
    if (n.contains('stair') || n.contains('escada')) return 'escada';
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

  static Decisao decidir(List<Obstaculo> deteccoes) {
    final validos = deteccoes
        .where((o) => o.confianca >= confiancaMinima && o.area >= areaMinima)
        .toList();

    final bloqueadas = <Zona>{};
    for (final o in validos) {
      for (final z in Zona.values) {
        if (_ocupa(o.caixa, z)) bloqueadas.add(z);
      }
    }

    Obstaculo? principal;
    for (final o in validos) {
      if (principal == null || o.area > principal.area) principal = o;
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
    return Decisao(orientacao, bloqueadas, principal);
  }
}
