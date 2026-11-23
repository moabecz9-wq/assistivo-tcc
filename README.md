# Aplicativo móvel para detecção de obstáculos e auxílio à mobilidade

Trabalho de Conclusão de Curso, Tecnologia em Análise e Desenvolvimento de
Sistemas, Centro Universitário Mater Dei (UNIMATER).

**Autor:** Moabe Diogenes Czarnobaj
**Orientador:** Prof. Msc. Giovani Fabris Marcarini

## Sobre

Protótipo de aplicativo Android que usa a câmera do smartphone e visão
computacional para identificar obstáculos (pessoa, escada e piso tátil), determinar
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
   o próprio painel calcula as métricas da avaliação.

## Estrutura

| Caminho | Conteúdo |
|---|---|
| `lib/main.dart` | Tela principal e integração |
| `lib/navigation_logic.dart` | Zonas e decisão de desvio |
| `lib/feedback_service.dart` | Voz e vibração |
| `lib/test_logger.dart` | Registro dos testes em CSV |
| `test/` | Testes automatizados da lógica |
| `docs/` | Requisitos e estudo das tecnologias |
| `resultados/` | CSV dos testes e métricas |

## Como executar

    flutter pub get
    flutter test
    flutter run

Requer Flutter, Android SDK e um celular Android (minSdk 24) com depuração USB.

## Métricas

As métricas são calculadas no painel de testes do app (botão Métricas). O CSV dos ensaios e o resultado do treino ficam em `resultados/`.

## Licenças e atribuições

- Plugin `ultralytics_yolo` e modelos YOLO: AGPL-3.0 (Ultralytics).
- Datasets de escada: Roboflow Universe (ver `docs/TECNOLOGIAS.md` para autores e
  licenças).
## Modelo de detecção

Modelo único YOLO11n, treinado no Google Colab, com 4 classes: pessoa (person),
escada (stairs), piso tátil de guia (go-block) e piso tátil de alerta
(stop-block). Pessoa e escada bloqueiam a região; o piso tátil é tratado como guia
e o de alerta gera um aviso. Resultado do treino em `resultados/metricas_treino.md`.

## Datasets utilizados

- Pessoas: COCO 2017 (anotações CC BY 4.0).
- Piso tátil: Roboflow Universe, projeto `detection2-9wpxq-awkvj` (CC BY 4.0).
- Escadas: Roboflow, projeto `stairs-lusiz-ggfgo` (verificar a licença no `data.yaml` do dataset).
