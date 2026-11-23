# Resultado do treino do modelo (conjunto de teste)

Modelo: YOLO11n, 40 épocas, 640x640, treinado no Google Colab (GPU T4).
Arquivo no app: assets/models/obstaculos_v1.tflite
Conjunto de teste: 501 imagens, 1198 instâncias.

| Classe | Precisão | Recall | AP50 | AP50-95 |
|---|---|---|---|---|
| Pessoa (person) | 0,699 | 0,574 | 0,647 | 0,382 |
| Escada (stairs) | 0,850 | 0,782 | 0,849 | 0,464 |
| Piso tátil de guia (go-block) | 0,783 | 0,765 | 0,845 | 0,624 |
| Piso tátil de alerta (stop-block) | 0,751 | 0,858 | 0,883 | 0,719 |
| Geral | 0,771 | 0,745 | 0,806 | 0,547 |

Observações:
- O tempo de inferência (cerca de 4 ms por imagem) foi medido na GPU do Colab e não representa o tempo no celular.
- Pessoa é a classe mais fraca (recall 0,574). Hipóteses: pessoas pequenas ou parcialmente cobertas no COCO e pessoas sem rótulo nas imagens de escada e piso tátil.
- As métricas do sistema completo (detecção, localização, decisão, tempo de resposta) vêm dos ensaios no celular.
