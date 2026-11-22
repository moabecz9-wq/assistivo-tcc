import 'dart:io';
import 'package:path_provider/path_provider.dart';

class TestLogger {
  static const cabecalho =
      'data_hora,classe_real,classe_detectada,posicao_real,posicao_detectada,'
      'direcao_esperada,direcao_recomendada,latencia_ms,condicao';

  final List<List<String>> _linhas = [];
  File? _arquivo;

  int get total => _linhas.length;

  Future<void> carregar() async {
    final dir = await getApplicationDocumentsDirectory();
    _arquivo = File('${dir.path}/ensaios.csv');
    if (await _arquivo!.exists()) {
      final linhas = await _arquivo!.readAsLines();
      for (final l in linhas.skip(1)) {
        if (l.trim().isNotEmpty) _linhas.add(l.split(','));
      }
    }
  }

  Future<void> registrar(List<String> campos) async {
    _linhas.add(campos);
    await _arquivo?.writeAsString('${csv()}\n');
  }

  Future<void> limpar() async {
    _linhas.clear();
    await _arquivo?.writeAsString('$cabecalho\n');
  }

  String csv() => [cabecalho, ..._linhas.map((l) => l.join(','))].join('\n');

  String _pct(int a, int b) =>
      b == 0 ? '-' : '${(100 * a / b).toStringAsFixed(1)}% ($a/$b)';

  /// 1 classe_real, 2 classe_detectada, 3 pos_real, 4 pos_detectada,
  /// 5 esperada, 6 recomendada, 7 latencia.
  String metricas() {
    if (_linhas.isEmpty) return 'Nenhum ensaio registrado.';
    final comObs = _linhas.where((l) => l[1] != 'nenhum').toList();
    final semObs = _linhas.where((l) => l[1] == 'nenhum').toList();

    final classeOk = comObs.where((l) => l[2] == l[1]).length;
    final loc = comObs.where((l) => l[4] == l[3]).length;
    final dec = _linhas.where((l) => l[5] == l[6]).length;
    final fp = semObs.where((l) => l[2] != 'nenhum').length;
    final fn = comObs.where((l) => l[2] == 'nenhum').length;
    final lat = _linhas
        .map((l) => int.tryParse(l[7]))
        .whereType<int>()
        .where((v) => v > 0)
        .toList();
    final latMedia =
        lat.isEmpty ? '-' : '${(lat.reduce((a, b) => a + b) / lat.length).toStringAsFixed(0)} ms';

    return 'Ensaios: ${_linhas.length}\n'
        'Identificação correta da classe: ${_pct(classeOk, comObs.length)}\n'
        'Localização correta: ${_pct(loc, comObs.length)}\n'
        'Decisão correta: ${_pct(dec, _linhas.length)}\n'
        'Falsos positivos: $fp\n'
        'Falsos negativos: $fn\n'
        'Tempo médio até o início da fala: $latMedia';
  }
}
