import 'dart:io';
import 'package:path_provider/path_provider.dart';

class TestLogger {
  static const cabecalho =
      'data_hora,classe,posicao_real,posicao_detectada,direcao_esperada,direcao_recomendada,latencia_ms';

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

  /// Colunas: 2 real, 3 detectada, 4 esperada, 5 recomendada, 6 latencia.
  String metricas() {
    if (_linhas.isEmpty) return 'Nenhum ensaio registrado.';
    final comObs = _linhas.where((l) => l[2] != 'nenhum').toList();
    final semObs = _linhas.where((l) => l[2] == 'nenhum').toList();

    final det = comObs.where((l) => l[3] != 'nenhum').length;
    final loc = comObs.where((l) => l[3] == l[2]).length;
    final dec = _linhas.where((l) => l[4] == l[5]).length;
    final fp = semObs.where((l) => l[3] != 'nenhum').length;
    final fn = comObs.where((l) => l[3] == 'nenhum').length;
    final lat = _linhas.map((l) => int.tryParse(l[6]) ?? 0).toList();
    final latMedia = lat.reduce((a, b) => a + b) / lat.length;

    return 'Ensaios: ${_linhas.length}\n'
        'Taxa de detecção: ${_pct(det, comObs.length)}\n'
        'Localização correta: ${_pct(loc, comObs.length)}\n'
        'Decisão correta: ${_pct(dec, _linhas.length)}\n'
        'Falsos positivos: $fp\n'
        'Falsos negativos: $fn\n'
        'Tempo médio de resposta: ${latMedia.toStringAsFixed(1)} ms';
  }
}
