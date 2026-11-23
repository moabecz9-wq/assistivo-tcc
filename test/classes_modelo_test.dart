import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:assistivo_tcc/navigation_logic.dart';

void main() {
  test('traduz as classes do modelo', () {
    expect(NavigationLogic.traduzirClasse('person'), 'pessoa');
    expect(NavigationLogic.traduzirClasse('stairs'), 'escada');
    expect(NavigationLogic.traduzirClasse('go-block'), 'piso tátil');
    expect(NavigationLogic.traduzirClasse('stop-block'), 'piso tátil de alerta');
  });

  test('piso tátil de guia não bloqueia o centro', () {
    final d = NavigationLogic.decidir([
      Obstaculo(
          classe: 'piso tátil',
          confianca: 0.9,
          caixa: Rect.fromLTWH(0.3, 0.4, 0.4, 0.4)),
    ]);
    expect(d.orientacao, Orientacao.livre);
  });

  test('piso tátil de alerta gera atenção sem bloquear', () {
    final d = NavigationLogic.decidir([
      Obstaculo(
          classe: 'piso tátil de alerta',
          confianca: 0.9,
          caixa: Rect.fromLTWH(0.3, 0.4, 0.4, 0.4)),
    ]);
    expect(d.orientacao, Orientacao.livre);
    expect(d.mensagem.startsWith('atenção'), true);
  });

  test('escada no centro com a esquerda livre manda desviar pela esquerda', () {
    final d = NavigationLogic.decidir([
      Obstaculo(
          classe: 'escada',
          confianca: 0.9,
          caixa: Rect.fromLTWH(0.3, 0.3, 0.4, 0.4)),
    ]);
    expect(d.orientacao, Orientacao.desviarEsquerda);
  });
}
