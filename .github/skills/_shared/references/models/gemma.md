# Gemma Family

Includes Gemma 4 and TranslateGemma.

## Variant Snapshot

| Model | Style | Total / Active Params | Context | Primary Use | License |
| ----- | ----- | --------------------- | ------- | ----------- | ------- |
| Gemma 4 E2B | Dense | ~2B effective | 128k+ | Edge / mobile | Apache 2.0 |
| Gemma 4 E4B | Dense | ~4B effective | 128k+ | Lightweight multimodal | Apache 2.0 |
| Gemma 4 26B | MoE | 26B | Up to 256k | Larger multimodal reasoning | Apache 2.0 |
| Gemma 4 31B | Dense | 31B | Up to 256k | Strong on-prem generalist | Apache 2.0 |
| TranslateGemma 4B / 12B / 27B | Dense specialist | 4B / 12B / 27B | Translation pipeline scale | Translation + OCR-aware image text translation | Open-weight |

## Architecture and Innovations

- Gemma 4 is the Google DeepMind open-weight line for advanced reasoning and agentic workflows.
- The family combines dense and MoE variants with multimodal support.
- TranslateGemma is not a generic chat model; it is a task-focused translation family built on Gemma 3 foundations.

Cross-references:

- Architecture families: `../../model-architectures/references/architecture-catalog.md`
- Serving frameworks and quantization choices: `../../model-inference/references/serving-frameworks.md`

## Training and Post-Training Notes

- Gemma 4 is derived from the broader Gemini technology stack.
- TranslateGemma is described as using distillation from larger Gemini / Gemma 3 translation-capable models, then SFT + RL with translation quality reward models.

## Inference and Deployment Profiles

| Deployment Profile | Good Candidates | Notes |
| ------------------ | --------------- | ----- |
| Mobile / edge | Gemma 4 E2B / E4B, TranslateGemma 4B | Lightweight and compatible with small-device workflows |
| 1 x 12-24 GB GPU | TranslateGemma 12B | Dedicated translation engine |
| 1 x 48-80 GB GPU | Gemma 4 31B, TranslateGemma 27B | Strong single-node deployment tier |
| Multi-GPU | Gemma 4 26B MoE if serving stack needs it | Less universal than dense 31B |

Serving notes:

- Gemma 4 is a strong general-purpose open-weight option for teams that want Apache 2.0 and multimodality.
- TranslateGemma is the better choice when translation quality matters more than general LLM flexibility.

## Strengths and Positioning

| Model | Strength |
| ----- | ----------------- |
| Gemma 4 | High intelligence-per-parameter, strong reasoning and agentic positioning, with top-tier arena placement in cited benchmarks |
| TranslateGemma 12B | Beats Gemma 3 27B on WMT24++ / MetricX in cited benchmarks |

## Repos and Weights

- Gemma 4 overview: <https://ai.google.dev/gemma/docs/core>
- Gemma 4 product page: <https://deepmind.google/models/gemma/gemma-4/>
- Kaggle Gemma 4: <https://www.kaggle.com/models/google/gemma-4/code>
- TranslateGemma Ollama: <https://ollama.com/library/translategemma>

## Sources

- <https://blog.google/innovation-and-ai/technology/developers-tools/gemma-4/>
- <https://deepmind.google/models/gemma/gemma-4/>
- <https://ai.google.dev/gemma/docs/core>
- <https://www.kaggle.com/models/google/gemma-4/code>
- <https://www.blogdumoderateur.com/google-devoile-translategemma-modeles-traduction-open-source/>
- <https://www.nurix.ai/resources/translategemma-ai-translation-model-explained>
- <https://ollama.com/library/translategemma>
