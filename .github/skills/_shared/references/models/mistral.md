# Mistral Family

Includes Mistral 7B, Mixtral 8x7B / 8x22B, Mistral 3, Ministral 3, Mistral Small 3 / 3.1, and Devstral 2 / Small 2.

## Variant Snapshot

| Model | Style | Total / Active Params | Context | Primary Use | License |
| ----- | ----- | --------------------- | ------- | ----------- | ------- |
| Mistral 7B | Dense | 7B | Long context via sliding window | General-purpose local LLM | Apache 2.0 |
| Mixtral 8x7B | Sparse MoE | ~47B / ~13B active | Long context | Efficient MoE generalist | Open-weight |
| Mixtral 8x22B | Sparse MoE | Larger MoE line | Long context | Higher-capacity MoE | Open-weight |
| Ministral 3 3B / 8B / 14B | Dense multimodal | 3B / 8B / 14B | Up to 256k (128k for some reasoning variants) | General + reasoning + image | Apache 2.0 |
| Mistral Large 3 | Sparse MoE | 675B / 41B active | Long context | Frontier serving | Open-weight |
| Mistral Small 3 / 3.1 | Dense | 24B | 256k | Strong on-prem workhorse | Apache 2.0 |
| Devstral 2 | Code-specialized | 123B | 256k | Agentic code workflows | Verify release terms |
| Devstral Small 2 | Code-specialized | 24B | 256k | Internal code engine on 1 GPU | Apache 2.0 |

## Architecture and Innovations

- Mistral 7B popularized efficient sliding-window attention in a strong 7B open-weight release.
- Mixtral established sparse top-2 MoE as a mainstream open-weight pattern.
- Ministral 3 is a dense multimodal line trained via cascade distillation from a 24B parent model.
- Mistral Large 3 extends the family into frontier sparse MoE territory.
- Devstral applies the Mistral ecosystem to software engineering and code-agent workflows.

Cross-references:

- Sliding-window attention and modern attention patterns: `../../model-architectures/references/attention-mechanisms.md`
- MoE routing and serving details for Mixtral / Mistral Large 3: `../../cutting-edge-architectures/references/moe-sparse-routing.md`

## Training and Post-Training Notes

- Mistral Large 3 was trained from scratch on about 3,000 NVIDIA H200 GPUs.
- Ministral 3 uses a cascade distillation path from Mistral Small 3.1, combining pruning, distillation, and continued training.
- Devstral focuses post-training on code understanding, repository exploration, multi-file editing, and agentic coding tasks.

## Inference and Deployment Profiles

| Deployment Profile | Good Candidates | Notes |
| ------------------ | --------------- | ----- |
| CPU / edge | Ministral 3 3B | GGUF-friendly, smallest Mistral family entry |
| 1 x 16-24 GB GPU | Ministral 3 8B | Strong general-purpose on-prem option |
| 1 x 48-80 GB GPU | Ministral 3 14B, Mistral Small 3 / 3.1, Devstral Small 2 | Best balance for local reasoning or code |
| 4-8 x 80 GB GPUs | Mistral Large 3, Devstral 2 | Large sparse or code-specialized deployments |
| Cluster | Mistral Large 3 | Use MoE-aware serving stack |

Serving notes:

- Dense variants fit standard vLLM / TGI / llama.cpp deployment patterns.
- Mixtral and Mistral Large 3 benefit from MoE-aware backends and expert-parallel-aware serving.
- Devstral Small 2 is a good internal code model when 24B dense fits your GPU budget.

## Strengths and Positioning

| Model | Strength |
| ----- | ----------------- |
| Mistral 7B | Surpassed earlier larger open models on many general benchmarks at release |
| Mixtral 8x7B | Strong code, math, multilingual, and long-context efficiency for open MoE |
| Ministral 3 14B Reasoning | Around 85% on AIME 2025 |
| Mistral Small 3 | Over 81% MMLU and about 150 tok/s in release materials |
| Devstral 2 | Around 72.2% SWE-Bench Verified |
| Devstral Small 2 | Around 68.0% SWE-Bench Verified |

## Repos and Weights

- Mistral catalog: <https://docs.mistral.ai/getting-started/models>
- Ministral 3 paper: <https://arxiv.org/abs/2601.08584>
- Devstral Small 2 weights: <https://huggingface.co/mistralai/Devstral-Small-2-24B-Instruct-2512>
- Devstral 2 release: <https://mistral.ai/news/devstral-2-vibe-cli>
- Devstral 2 in Ollama: <https://ollama.com/library/devstral-2>

## Sources

- <https://dataguru.cc/blog/mistral-7b-and-mixtral-explained-powerful-open-weight-models-by-mistral-ai/>
- <https://mistral.ai/news/mistral-3>
- <https://www.datacamp.com/blog/mistral-3>
- <https://arxiv.org/abs/2601.08584>
- <https://mistral.ai/news/mistral-small-3>
- <https://mistral.ai/news/mistral-small-3-1>
- <https://mistral.ai/news/devstral-2-vibe-cli>
- <https://docs.mistral.ai/models/devstral-small-2-25-12>
