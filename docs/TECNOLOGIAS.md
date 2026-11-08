# Estudo das tecnologias

## Critérios (proposta, seção 5)

Capacidade de detecção, desempenho em dispositivos móveis, execução local,
documentação e adequação às classes definidas.

## Alternativas avaliadas

| Tecnologia | Execução local | Classes próprias | Observação |
|---|---|---|---|
| ML Kit (detecção de objetos) | Sim | Limitado (modelo próprio possível, com ressalvas) | O detector padrão trabalha com categorias genéricas e não distingue "pessoa" ou "escada". **Confirmar na documentação atual antes de citar.** |
| YOLO (Ultralytics) | Sim (TFLite/LiteRT) | Sim (treinamento complementar) | Plugin oficial para Flutter, modelos pequenos (família nano), ajuste fino com dataset próprio. |

## Decisão

- **Visão computacional:** YOLO via plugin `ultralytics_yolo`, com modelo oficial
  (COCO) para pessoa e objetos e treinamento complementar para escada.
- **Aplicativo:** Flutter (Dart), Android. Justificativa: desenvolvimento
  multiplataforma, integração simples com modelos YOLO locais e acesso a câmera,
  voz e vibração.
- **Voz:** `flutter_tts`, em português do Brasil.
- **Vibração:** `vibration`.
- **Registro:** CSV local, gerado pelo próprio aplicativo.

## Licenças

- `ultralytics_yolo` e modelos Ultralytics: AGPL-3.0. Citar na monografia.

## Datasets de escada considerados (Roboflow Universe)

Conferir qualidade, quantidade e licença antes de usar, e preencher a coluna final.

| Dataset | Autor | Licença | Usado? |
|---|---|---|---|
| Stairs_Detection | ObjectDetectionArena | MIT | |
| stairs | forward | CC BY 4.0 | |
| stair detection | SOVAR | CC BY 4.0 | |
| Stairs | sphyxia A | CC BY 4.0 | |

Para CC BY 4.0, a atribuição aos autores é obrigatória; o Roboflow fornece a
citação em BibTeX na página de cada dataset.