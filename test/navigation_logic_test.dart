import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:assistivo_tcc/navigation_logic.dart';

Obstaculo obs(String classe, double l, double r) => Obstaculo(
      classe: classe,
      confianca: 0.9,
      caixa: Rect.fromLTRB(l, 0.3, r, 0.8),
    );

void main() {
  test('sem detecções: caminho livre', () {
    expect(NavigationLogic.decidir([]).orientacao, Orientacao.livre);
  });

  test('obstáculo no centro: desvia pela esquerda', () {
    final d = NavigationLogic.decidir([obs('pessoa', 0.4, 0.6)]);
    expect(d.orientacao, Orientacao.desviarEsquerda);
  });

  test('centro e esquerda bloqueados: desvia pela direita', () {
    final d = NavigationLogic.decidir([obs('pessoa', 0.0, 0.6)]);
    expect(d.orientacao, Orientacao.desviarDireita);
  });

  test('tudo bloqueado: pare', () {
    final d = NavigationLogic.decidir([obs('escada', 0.0, 1.0)]);
    expect(d.orientacao, Orientacao.parar);
  });

  test('piso tátil não bloqueia e é informado', () {
    final d = NavigationLogic.decidir([obs('piso tátil', 0.4, 0.6)]);
    expect(d.orientacao, Orientacao.livre);
    expect(d.mensagem, contains('piso tátil'));
  });

  test('traduzirClasse', () {
    expect(NavigationLogic.traduzirClasse('person'), 'pessoa');
    expect(NavigationLogic.traduzirClasse('stairs'), 'escada');
    expect(NavigationLogic.traduzirClasse('tactile_paving'), 'piso tátil');
    expect(NavigationLogic.traduzirClasse('chair'), 'objeto');
  });
}
