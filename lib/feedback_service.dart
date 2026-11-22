import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vibration/vibration.dart';
import 'navigation_logic.dart';

class FeedbackService {
  final FlutterTts _tts = FlutterTts();
  String? _ultima;
  DateTime _ultimoEm = DateTime.fromMillisecondsSinceEpoch(0);
  Completer<void>? _aguardandoInicio;

  Future<void> iniciar() async {
    await _tts.setLanguage('pt-BR');
    await _tts.setSpeechRate(0.5);
    _tts.setStartHandler(() {
      final c = _aguardandoInicio;
      if (c != null && !c.isCompleted) c.complete();
    });
  }

  /// Fala e vibra. Retorna a latência em ms (de [inicio] até o começo da
  /// fala) ou null se nada foi emitido (mensagem repetida / muito cedo).
  Future<int?> emitir(Decisao d, DateTime inicio) async {
    final agora = DateTime.now();
    final msg = d.mensagem;
    final mudou = msg != _ultima;
    final delta = agora.difference(_ultimoEm);

    if (mudou && delta < const Duration(seconds: 1)) return null;
    if (!mudou) {
      if (d.orientacao == Orientacao.livre) return null;
      if (delta < const Duration(seconds: 4)) return null;
    }

    _ultima = msg;
    _ultimoEm = agora;
    _aguardandoInicio = Completer<void>();
    _vibrar(d.orientacao);
    await _tts.speak(msg);
    await _aguardandoInicio!.future
        .timeout(const Duration(seconds: 2), onTimeout: () {});
    return DateTime.now().difference(inicio).inMilliseconds;
  }

  Future<void> _vibrar(Orientacao o) async {
    final tem = await Vibration.hasVibrator();
    if (tem != true) return;
    switch (o) {
      case Orientacao.desviarEsquerda:
        Vibration.vibrate(pattern: [0, 200]);
        break;
      case Orientacao.desviarDireita:
        Vibration.vibrate(pattern: [0, 200, 100, 200]);
        break;
      case Orientacao.parar:
        Vibration.vibrate(pattern: [0, 700]);
        break;
      case Orientacao.livre:
        Vibration.vibrate(pattern: [0, 80]);
        break;
    }
  }
}
