import 'package:flutter_tts/flutter_tts.dart';
import 'package:vibration/vibration.dart';
import 'navigation_logic.dart';

class FeedbackService {
  final FlutterTts _tts = FlutterTts();
  String? _ultima;
  DateTime _ultimoEm = DateTime.fromMillisecondsSinceEpoch(0);

  Future<void> iniciar() async {
    await _tts.setLanguage('pt-BR');
    await _tts.setSpeechRate(0.5);
  }

  /// Fala e vibra. Evita repetir a mesma mensagem a cada frame.
  /// Retorna true se emitiu uma orientação.
  Future<bool> emitir(Decisao d) async {
    final agora = DateTime.now();
    final msg = d.mensagem;
    final mudou = msg != _ultima;
    final delta = agora.difference(_ultimoEm);

    if (mudou && delta < const Duration(seconds: 1)) return false;
    if (!mudou) {
      if (d.orientacao == Orientacao.livre) return false;
      if (delta < const Duration(seconds: 4)) return false;
    }

    _ultima = msg;
    _ultimoEm = agora;
    await _tts.speak(msg);
    _vibrar(d.orientacao);
    return true;
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
