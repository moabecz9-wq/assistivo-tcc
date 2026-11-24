import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:assistivo_tcc/navigation_logic.dart';

void main() {
  test('obstáculo longe é ignorado', () {
    final d = NavigationLogic.decidir([
      Obstaculo(
          classe: 'pessoa',
          confianca: 0.9,
          caixa: Rect.fromLTWH(0.44, 0.3, 0.12, 0.3)),
    ]);
    expect(d.orientacao, Orientacao.livre);
    expect(d.principal, isNull);
  });

  test('obstáculo perto no centro manda desviar', () {
    final d = NavigationLogic.decidir([
      Obstaculo(
          classe: 'pessoa',
          confianca: 0.9,
          caixa: Rect.fromLTWH(0.3, 0.2, 0.4, 0.5)),
    ]);
    expect(d.orientacao, Orientacao.desviarEsquerda);
  });

  test('prefere o lado sem obstáculo longe, sem avisar o longe', () {
    final d = NavigationLogic.decidir([
      Obstaculo(
          classe: 'pessoa',
          confianca: 0.9,
          caixa: Rect.fromLTWH(0.3, 0.2, 0.4, 0.5)),
      Obstaculo(
          classe: 'escada',
          confianca: 0.9,
          caixa: Rect.fromLTWH(0.05, 0.3, 0.15, 0.25)),
    ]);
    expect(d.orientacao, Orientacao.desviarDireita);
    expect(d.mensagem.contains('escada'), false);
  });

  test('estabilizador só muda depois de vários quadros', () {
    final est = Estabilizador(quadros: 3);
    final livre = NavigationLogic.decidir([]);
    final perto = NavigationLogic.decidir([
      Obstaculo(
          classe: 'pessoa',
          confianca: 0.9,
          caixa: Rect.fromLTWH(0.3, 0.2, 0.4, 0.5)),
    ]);
    expect(est.filtrar(livre).chave, 'livre');
    expect(est.filtrar(perto).chave, 'livre');
    expect(est.filtrar(perto).chave, 'livre');
    expect(est.filtrar(perto).chave, 'esquerda');
  });
}
