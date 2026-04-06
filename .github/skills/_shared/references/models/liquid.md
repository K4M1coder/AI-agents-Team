# Liquid AI LFM Family

Includes Liquid Foundation Models and LFM2.5-1.2B-Thinking.

## Variant Snapshot

| Model | Style | Params | Context | Primary Use | Notes |
| ----- | ----- | ------ | ------- | ----------- | ----- |
| LFM family | Hybrid non-GPT | Varies | Multimodal | Research / alternative sequence modeling | Shared Liquid stack |
| LFM2.5-1.2B-Thinking | Hybrid reasoning model | ~1.17B | 32,768 | Edge reasoning / on-device | Under 1 GB deployment target |

## Architecture and Innovations

- Liquid AI positions LFM as an alternative to standard transformer-only design.
- The family emphasizes adaptive computation, weight sharing, feature sharing, and multimodal support.
- LFM2.5-1.2B-Thinking is the clearest practical model in the family for real deployment planning.

## Training and Post-Training Notes

- Liquid AI reports roughly 28T training tokens for LFM2.5-1.2B-Thinking.
- The architecture is described as a hybrid stack with convolution-like LIV blocks plus GQA attention blocks.

## Inference and Deployment Profiles

| Deployment Profile | Good Candidates | Notes |
| ------------------ | --------------- | ----- |
| Mobile / edge | LFM2.5-1.2B-Thinking | Designed specifically for on-device reasoning |
| CPU-first | LFM2.5-1.2B-Thinking | Good offline use case |
| Lightweight local GPU | LFM2.5-1.2B-Thinking | Small enough to be a utility reasoning sidecar |

Serving notes:

- This is a strong choice for offline reasoning utilities, mobile experiences, and low-cost agent support tasks.
- Not a replacement for large code or frontier reasoning models; use it as an edge or embedded component.

## Strengths and Positioning

| Model | Strength |
| ----- | ----------------- |
| LFM2.5-1.2B-Thinking | Strong reasoning for a ~1.2B model; capable enough to rival much larger models on some cited benchmarks |

## Repos and Weights

- Repo: <https://github.com/Decentralised-AI/LFM-Liquid-AI-Liquid-Foundation-Models>
- Blog: <https://www.liquid.ai/blog/lfm2-5-1-2b-thinking-on-device-reasoning-under-1gb>
- HF weights: <https://huggingface.co/LiquidAI/LFM2.5-1.2B-Thinking>
- Ollama: <https://ollama.com/library/lfm2.5-thinking>

## Sources

- <https://github.com/Decentralised-AI/LFM-Liquid-AI-Liquid-Foundation-Models>
- <https://www.liquid.ai/blog/lfm2-5-1-2b-thinking-on-device-reasoning-under-1gb>
- <https://huggingface.co/LiquidAI/LFM2.5-1.2B-Thinking>
- <https://ollama.com/library/lfm2.5-thinking>
- <https://openrouter.ai/liquid/lfm-2.5-1.2b-thinking:free>
