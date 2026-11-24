import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:assistivo_tcc/navigation_logic.dart';

void main() {
  test('piso tátil de guia à esquerda leva para a esquerda', () {
    final d = NavigationLogic.decidir([
      Obstaculo(
          classe: 'piso tátil',
          confianca: 0.9,
          caixa: Rect.fromLTWH(0.02, 0.5, 0.2, 0.4)),
    ]);
    expect(d.orientacao, Orientacao.desviarEsquerda);
    expect(d.mensagem.contains('piso tátil'), true);
  });

  test('piso tátil de guia à direita leva para a direita', () {
    final d = NavigationLogic.decidir([
      Obstaculo(
          classe: 'piso tátil',
          confianca: 0.9,
          caixa: Rect.fromLTWH(0.78, 0.5, 0.2, 0.4)),
    ]);
    expect(d.orientacao, Orientacao.desviarDireita);
  });

  test('piso tátil de guia no centro manda seguir em frente por ele', () {
    final d = NavigationLogic.decidir([
      Obstaculo(
          classe: 'piso tátil',
          confianca: 0.9,
          caixa: Rect.fromLTWH(0.3, 0.5, 0.4, 0.4)),
    ]);
    expect(d.orientacao, Orientacao.livre);
    expect(d.mensagem, 'siga em frente pelo piso tátil');
  });

  test('obstáculo perto no centro desvia pelo lado do piso tátil', () {
    final d = NavigationLogic.decidir([
      Obstaculo(
          classe: 'pessoa',
          confianca: 0.9,
          caixa: Rect.fromLTWH(0.3, 0.2, 0.4, 0.5)),
      Obstaculo(
          classe: 'piso tátil',
          confianca: 0.9,
          caixa: Rect.fromLTWH(0.75, 0.5, 0.2, 0.3)),
    ]);
    expect(d.orientacao, Orientacao.desviarDireita);
  });
}
