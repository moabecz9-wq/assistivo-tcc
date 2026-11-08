# Aplicativo móvel para detecção de obstáculos e auxílio à mobilidade

Trabalho de Conclusão de Curso, Tecnologia em Análise e Desenvolvimento de
Sistemas, Centro Universitário Mater Dei (UNIMATER).

**Autor:** Moabe Diogenes Czarnobaj
**Orientador:** Prof. Msc. Giovani Fabris Marcarini

## Sobre

Protótipo de aplicativo Android que usa a câmera do smartphone e visão
computacional para identificar obstáculos (pessoa, escada e objeto), determinar
sua posição aproximada (esquerda, centro ou direita) e orientar o desvio por
áudio e vibração, com processamento local, em ambiente controlado.

> O sistema é um protótipo de pesquisa. Não substitui bengala, cão-guia ou
> outros recursos especializados de mobilidade.

## Como funciona

1. A câmera envia os frames ao detector YOLO (plugin `ultralytics_yolo`).
2. A camada própria (`lib/navigation_logic.dart`) divide o campo visual em três
   regiões, verifica quais estão bloqueadas e escolhe a orientação.
3. `lib/feedback_service.dart` fala ("desvie pela esquerda", "desvie pela
   direita", "caminho livre, siga em frente") e vibra.
4. O painel de testes grava cada ensaio em CSV (`lib/test_logger.dart`) e
   `bin/metricas.dart` calcula as métricas da avaliação.

## Estrutura

| Caminho | Conteúdo |
|---|---|
| `lib/main.dart` | Tela principal e integração |
| `lib/navigation_logic.dart` | Zonas e decisão de desvio |
| `lib/feedback_service.dart` | Voz e vibração |
| `lib/test_logger.dart` | Registro dos testes em CSV |
| `bin/metricas.dart` | Cálculo das métricas |
| `test/` | Testes automatizados da lógica |
| `docs/` | Requisitos e estudo das tecnologias |
| `treino/` | Montagem do dataset e treinamento da classe escada |
| `resultados/` | CSV dos testes e métricas |

## Como executar

    flutter pub get
    flutter test
    flutter run

Requer Flutter, Android SDK e um celular Android (minSdk 24) com depuração USB.

## Métricas

    dart run bin/metricas.dart resultados/testes.csv

## Licenças e atribuições

- Plugin `ultralytics_yolo` e modelos YOLO: AGPL-3.0 (Ultralytics).
- Datasets de escada: Roboflow Universe (ver `docs/TECNOLOGIAS.md` para autores e
  licenças).