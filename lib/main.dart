import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import 'feedback_service.dart';
import 'navigation_logic.dart';
import 'test_logger.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TelaDeteccao(),
  ));
}

class TelaDeteccao extends StatefulWidget {
  const TelaDeteccao({super.key});

  @override
  State<TelaDeteccao> createState() => _TelaDeteccaoState();
}

class _TelaDeteccaoState extends State<TelaDeteccao> {
  final _feedback = FeedbackService();
  final _logger = TestLogger();

  Decisao? _decisao;
  int _latenciaMs = 0;
  bool _painelAberto = true;

  String _classeReal = 'nenhum';
  String _posReal = 'nenhum';
  String _esperada = 'livre';
  String _condicao = 'boa';

  @override
  void initState() {
    super.initState();
    _feedback.iniciar();
    _logger.carregar();
  }

  void _aoDetectar(List<YOLOResult> resultados) {
    final inicio = DateTime.now();
    final obstaculos = resultados
        .map((r) => Obstaculo(
              classe: NavigationLogic.traduzirClasse(r.className),
              confianca: r.confidence,
              caixa: r.normalizedBox,
            ))
        .toList();
    final d = NavigationLogic.decidir(obstaculos);
    setState(() => _decisao = d);
    _feedback.emitir(d, inicio).then((ms) {
      if (ms != null && mounted) setState(() => _latenciaMs = ms);
    });
  }

  Future<void> _registrar() async {
    final d = _decisao;
    if (d == null) return;
    await _logger.registrar([
      DateTime.now().toIso8601String(),
      _classeReal,
      d.principal?.classe ?? 'nenhum',
      _posReal,
      d.principal?.zona.name ?? 'nenhum',
      _esperada,
      d.chave,
      '$_latenciaMs',
      _condicao,
    ]);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ensaio ${_logger.total} registrado')),
    );
  }

  void _mostrarMetricas() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Métricas'),
        content: Text(_logger.metricas()),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _logger.csv()));
              Navigator.pop(context);
            },
            child: const Text('Copiar CSV'),
          ),
          TextButton(
            onPressed: () async {
              await _logger.limpar();
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Limpar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _opcoes(String titulo, List<String> itens, String atual,
      void Function(String) aoMudar) {
    return Wrap(
      spacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(titulo, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ...itens.map((i) => ChoiceChip(
              label: Text(i, style: const TextStyle(fontSize: 12)),
              selected: atual == i,
              visualDensity: VisualDensity.compact,
              onSelected: (_) => setState(() => aoMudar(i)),
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = _decisao;
    return Scaffold(
      body: Stack(
        children: [
          YOLOView(
            modelPath: YOLO.defaultOfficialModel() ?? 'yolo26n',
            task: YOLOTask.detect,
            onResult: _aoDetectar,
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Row(
                children: [
                  for (int i = 0; i < 3; i++)
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white24),
                          color: (d?.bloqueadas.contains(Zona.values[i]) ??
                                  false)
                              ? Colors.red.withValues(alpha: 0.25)
                              : Colors.transparent,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                color: Colors.black87,
                padding: const EdgeInsets.all(12),
                child: Text(
                  d?.mensagem ?? 'Aguardando detecções...',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.black87,
              padding: const EdgeInsets.all(10),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Painel de testes (${_logger.total})',
                            style: const TextStyle(color: Colors.white)),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                              _painelAberto
                                  ? Icons.expand_more
                                  : Icons.expand_less,
                              color: Colors.white),
                          onPressed: () =>
                              setState(() => _painelAberto = !_painelAberto),
                        ),
                      ],
                    ),
                    if (_painelAberto) ...[
                      _opcoes(
                          'Classe real:',
                          ['nenhum', 'pessoa', 'escada', 'objeto'],
                          _classeReal,
                          (v) => _classeReal = v),
                      _opcoes(
                          'Posição real:',
                          ['nenhum', 'esquerda', 'centro', 'direita'],
                          _posReal,
                          (v) => _posReal = v),
                      _opcoes(
                          'Esperado:',
                          ['livre', 'esquerda', 'direita', 'parar'],
                          _esperada,
                          (v) => _esperada = v),
                      _opcoes(
                          'Condição:',
                          ['boa', 'pouca_luz', 'distante', 'sobreposto'],
                          _condicao,
                          (v) => _condicao = v),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          ElevatedButton(
                              onPressed: _registrar,
                              child: const Text('Registrar ensaio')),
                          const SizedBox(width: 8),
                          OutlinedButton(
                              onPressed: _mostrarMetricas,
                              child: const Text('Métricas')),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Protótipo de pesquisa. Não substitui bengala ou cão-guia.',
                        style: TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
