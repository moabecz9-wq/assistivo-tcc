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

  /// Piso tátil (direcional ou de alerta) é guia de caminho, não obstáculo.
  bool get ehGuia => classe == 'piso tátil' || classe == 'piso tátil de alerta';

  /// Piso tátil de alerta (stop-block): pede atenção, mas não bloqueia a zona.
  bool get ehAlerta => classe == 'piso tátil de alerta';

  /// Estimativa de proximidade pelo tamanho na imagem: objeto grande, ou com a
  /// base perto do fim da imagem (chão), está perto. Não é distância medida.
  bool get perto =>
      area >= NavigationLogic.areaPerto ||
      (caixa.bottom >= NavigationLogic.baseNoChao &&
          area >= NavigationLogic.areaPertoNoChao);

  Zona get zona {
    final cx = caixa.center.dx;
    if (cx < 1 / 3) return Zona.esquerda;
    if (cx > 2 / 3) return Zona.direita;
    return Zona.centro;
  }
}

class Decisao {
  final Orientacao orientacao;
  final Set<Zona> bloqueadas; // só o que está perto
  final Obstaculo? principal; // obstáculo perto mais próximo
  final Obstaculo? guia; // piso tátil
  final bool seguirGuia; // true quando a orientação é seguir o piso tátil

  const Decisao(
    this.orientacao,
    this.bloqueadas,
    this.principal,
    this.guia, {
    this.seguirGuia = false,
  });

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
    final nome = g.classe;
    switch (g.zona) {
      case Zona.esquerda:
        return ', $nome à esquerda';
      case Zona.direita:
        return ', $nome à direita';
      case Zona.centro:
        return ', $nome à frente';
    }
  }

  String get mensagem {
    final nome = principal?.classe ?? 'obstáculo';
    switch (orientacao) {
      case Orientacao.desviarEsquerda:
        if (seguirGuia) return 'piso tátil à esquerda, siga pela esquerda';
        return '$nome à frente, desvie pela esquerda';
      case Orientacao.desviarDireita:
        if (seguirGuia) return 'piso tátil à direita, siga pela direita';
        return '$nome à frente, desvie pela direita';
      case Orientacao.parar:
        return '$nome à frente, pare';
      case Orientacao.livre:
        if (guia?.ehAlerta ?? false) return 'atenção$_avisoGuia';
        if (seguirGuia) return 'siga em frente pelo piso tátil';
        return 'caminho livre, siga em frente$_avisoGuia';
    }
  }
}

class NavigationLogic {
  static const double confiancaMinima = 0.5;
  static const double areaMinima = 0.02;
  static const double sobreposicaoMinima = 0.2;
  static const double confiancaPessoa = 0.65;

  // Proximidade (ajuste fino): aumente areaPerto para avisar só o bem perto.
  static const double areaPerto = 0.08;
  static const double areaPertoNoChao = 0.04;
  static const double baseNoChao = 0.85;

  static double _minimaDe(String classe) =>
      classe == 'pessoa' ? confiancaPessoa : confiancaMinima;

  /// Traduz o nome da classe do modelo para o nome falado pelo app.
  /// Modelo atual: person, stairs, go-block, stop-block.
  static String traduzirClasse(String nome) {
    final n = nome.toLowerCase();
    if (n == 'person' || n == 'pessoa') return 'pessoa';
    if (n.contains('stair') || n.contains('escada')) return 'escada';
    if (n == 'stop-block') return 'piso tátil de alerta';
    if (n == 'go-block' ||
        n.contains('tactile') ||
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

  static Set<Zona> _zonasOcupadas(Iterable<Obstaculo> lista) {
    final zonas = <Zona>{};
    for (final o in lista) {
      for (final z in Zona.values) {
        if (_ocupa(o.caixa, z)) zonas.add(z);
      }
    }
    return zonas;
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
        .where((o) => o.confianca >= _minimaDe(o.classe) && o.area >= areaMinima)
        .toList();

    // Obstáculos: só o que está perto bloqueia e é anunciado.
    final obstaculos = validos.where((o) => o.perto && !o.ehGuia).toList();
    final longe = validos.where((o) => !o.perto && !o.ehGuia).toList();
    // Piso tátil de alerta: só perto. Piso de guia: vale em qualquer distância,
    // porque é o caminho preferido.
    final alerta = _maior(validos.where((o) => o.ehAlerta && o.perto));
    final guiaDir = _maior(validos.where((o) => o.ehGuia && !o.ehAlerta));

    final bloqueadas = _zonasOcupadas(obstaculos);
    final ocupadasLonge = _zonasOcupadas(longe);
    final livreEsq = !bloqueadas.contains(Zona.esquerda);
    final livreDir = !bloqueadas.contains(Zona.direita);
    final principal = _maior(obstaculos);

    // 1) Obstáculo perto no centro: desvia. Prefere o lado do piso tátil.
    if (bloqueadas.contains(Zona.centro)) {
      Orientacao o;
      if (livreEsq && livreDir) {
        if (guiaDir != null && guiaDir.zona == Zona.direita) {
          o = Orientacao.desviarDireita;
        } else if (guiaDir != null && guiaDir.zona == Zona.esquerda) {
          o = Orientacao.desviarEsquerda;
        } else {
          final esqComLonge = ocupadasLonge.contains(Zona.esquerda);
          final dirComLonge = ocupadasLonge.contains(Zona.direita);
          o = (esqComLonge && !dirComLonge)
              ? Orientacao.desviarDireita
              : Orientacao.desviarEsquerda;
        }
      } else if (livreEsq) {
        o = Orientacao.desviarEsquerda;
      } else if (livreDir) {
        o = Orientacao.desviarDireita;
      } else {
        o = Orientacao.parar;
      }
      return Decisao(o, bloqueadas, principal, guiaDir);
    }

    // 2) Piso tátil de alerta perto: atenção.
    if (alerta != null) {
      return Decisao(Orientacao.livre, bloqueadas, principal, alerta);
    }

    // 3) Caminho livre e há piso tátil de guia: segue o piso tátil.
    if (guiaDir != null) {
      final z = guiaDir.zona;
      if (z == Zona.esquerda && livreEsq) {
        return Decisao(Orientacao.desviarEsquerda, bloqueadas, principal,
            guiaDir,
            seguirGuia: true);
      }
      if (z == Zona.direita && livreDir) {
        return Decisao(Orientacao.desviarDireita, bloqueadas, principal,
            guiaDir,
            seguirGuia: true);
      }
      if (z == Zona.centro) {
        return Decisao(Orientacao.livre, bloqueadas, principal, guiaDir,
            seguirGuia: true);
      }
    }

    return Decisao(Orientacao.livre, bloqueadas, principal, guiaDir);
  }
}

/// Evita "tremedeira": a decisão só muda depois de vários quadros seguidos
/// com a mesma situação.
class Estabilizador {
  final int quadros;
  Decisao? _atual;
  Decisao? _candidata;
  int _cont = 0;

  Estabilizador({this.quadros = 4});

  static String _assinatura(Decisao d) =>
      '${d.chave}|${d.principal?.classe}|${d.guia?.classe}|${d.guia?.zona.name}|${d.seguirGuia}';

  Decisao filtrar(Decisao nova) {
    final atual = _atual;
    if (atual == null) {
      _atual = nova;
      return nova;
    }
    if (_assinatura(nova) == _assinatura(atual)) {
      _candidata = null;
      _cont = 0;
      _atual = nova;
      return nova;
    }
    final cand = _candidata;
    if (cand != null && _assinatura(cand) == _assinatura(nova)) {
      _cont++;
    } else {
      _candidata = nova;
      _cont = 1;
    }
    if (_cont >= quadros) {
      _atual = nova;
      _candidata = null;
      _cont = 0;
      return nova;
    }
    return atual;
  }
}
