# Kimi Family

Includes Kimi K2, K2-Mini, and K2.5 from Moonshot AI.

## Variant Snapshot

| Model | Style | Total / Active Params | Context | Primary Use | Notes |
| ----- | ----- | --------------------- | ------- | ----------- | ----- |
| Kimi K2 | Sparse MoE | ~1T / 32B active | 256k | Agentic multimodal reasoning | Very large open-weight MoE |
| Kimi-K2-Mini | Compressed K2 derivative | ~32.5B | Smaller than K2 | More accessible local experimentation | Community compression project |
| Kimi K2.5 | Multimodal agentic MoE | Very large | 256k | Vision, PDF, code, agents | Strong benchmark positioning |

## Architecture and Innovations

- Kimi K2 is framed as a very large MoE model with 32B activated parameters.
- K2.5 extends this into a native multimodal agentic model with image, PDF, and video-oriented positioning.
- K2.5 is designed around an agent-swarm style operating model where the system can coordinate many sub-agents.

Cross-references:

- Attention Residuals and deep-model optimization: `../../cutting-edge-architectures/references/attention-innovations.md`
- MoE routing and cluster deployment: `../../cutting-edge-architectures/references/moe-sparse-routing.md`

## Training and Post-Training Notes

- K2.5 was continually pretrained on about 15T text+vision tokens.
- The visual stack includes a MoonViT encoder.
- K2-Mini is not the canonical flagship, but a practical compression path for experimentation.

## Inference and Deployment Profiles

| Deployment Profile | Good Candidates | Notes |
| ------------------ | --------------- | ----- |
| Experimental local | K2-Mini | Most realistic way to test the family without a frontier cluster |
| High-end single-node | Quantized K2.5 variants | Requires very large unified memory or multi-GPU server |
| Multi-GPU / frontier | K2 / K2.5 full deployments | Best for multimodal agent systems |

Serving notes:

- Referenced deployment guides cite roughly 240 GB unified RAM/VRAM for a 1.8-bit K2.5 local run on B200-class hardware.
- This is a cluster-first family; local use depends heavily on quantization.

## Strengths and Positioning

| Model | Strength |
| ----- | ----------------- |
| K2 | Strong SOTA positioning on reasoning and coding in 2025 |
| K2.5 | Near-top proprietary competition on vision+code and multimodal agents |
| K2-Mini | Accessibility play, not flagship quality target |

## Repos and Weights

- Official page: <https://moonshotai.github.io/Kimi-K2/>
- K2-Mini: <https://github.com/WuKongAI-CMU/Kimi-K2-Mini>
- K2.5 NIM card: <https://build.nvidia.com/moonshotai/kimi-k2.5/modelcard>
- Local guide: <https://unsloth.ai/docs/models/kimi-k2.5>
- Ollama: <https://ollama.com/library/kimi-k2.5>

## Sources

- <https://moonshotai.github.io/Kimi-K2/>
- <https://github.com/WuKongAI-CMU/Kimi-K2-Mini>
- <https://build.nvidia.com/moonshotai/kimi-k2.5/modelcard>
- <https://unsloth.ai/docs/models/kimi-k2.5>
- <https://www.frandroid.com/culture-tech/intelligence-artificielle/2958953_tout-savoir-sur-kimi-k2-5-le-nouveau-concurrent-open-source-et-gratuit-qui-se-frotte-a-claude-4-5-et-gpt-5-2>
