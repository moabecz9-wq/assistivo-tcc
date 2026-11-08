# Requisitos do sistema

Derivados da proposta de TCC (seções 4 e 5).

## Escopo

Protótipo para auxiliar a identificação de obstáculos durante deslocamentos em
**ambiente controlado**. Classes iniciais: **pessoa, escada e objeto**. Novas
classes só entram se as funcionalidades essenciais estiverem validadas e houver
tempo.

## Requisitos funcionais

| Código | Requisito |
|---|---|
| RF01 | O sistema deve capturar frames da câmera do smartphone, posicionada à frente do usuário. |
| RF02 | O sistema deve identificar elementos das classes pessoa, escada e objeto, com classe, localização e confiança. |
| RF03 | O sistema deve classificar a posição horizontal de cada detecção em esquerda, centro ou direita. |
| RF04 | Com obstáculo na região central, o sistema deve verificar as regiões laterais e escolher uma alternativa de passagem. |
| RF05 | O sistema deve emitir as orientações "desvie pela esquerda", "desvie pela direita" e "caminho livre, siga em frente". |
| RF06 | O sistema deve informar por áudio o obstáculo identificado e a direção recomendada. |
| RF07 | O sistema deve usar vibração como alerta complementar. |
| RF08 | O sistema deve continuar analisando os frames durante o deslocamento e atualizar a orientação. |
| RF09 | O sistema deve registrar cada teste: classe e posição reais, identificação e posição indicadas, direção recomendada, acerto ou erro e tempo entre detecção e orientação. |
| RF10 | O sistema deve permitir calcular: taxa de detecção, localização correta, decisões corretas, falsos positivos, falsos negativos e tempo médio de resposta. |

## Requisitos não funcionais

| Código | Requisito |
|---|---|
| RNF01 | Processamento local no dispositivo, priorizando funcionamento sem conexão contínua. |
| RNF02 | Plataforma móvel Android. |
| RNF03 | Resposta em tempo real, adequada ao deslocamento (valor-alvo a definir com os testes). |
| RNF04 | Uso de recursos de síntese de voz e vibração do sistema operacional. |
| RNF05 | Camada própria de interpretação das detecções, independente do modelo. |

## Restrições e limites

- Testes apenas em ambiente controlado e seguro, com número reduzido de participantes.
- Se participantes sem deficiência visual simularem o uso, os resultados são
  **testes simulados de interação**, sem afirmar equivalência à experiência de
  pessoas cegas.
- Não se pretende demonstrar substituição de recursos de mobilidade nem eliminação
  de riscos.
- Falhas esperadas a registrar: iluminação, posição da câmera, distância,
  sobreposição de objetos e capacidade de processamento.