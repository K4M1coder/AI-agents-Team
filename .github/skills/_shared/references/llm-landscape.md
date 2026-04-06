# Open-Weight LLM Landscape

Shared entry point for recent open-weight model families relevant to on-prem deployment, evaluation, and agent system design.

This file is a routing layer, not the source of truth for each lab. Detailed notes live under `models/`.

## How to Use This Reference

- Use this file for first-pass routing by workload, hardware envelope, license posture, and deployment style.
- Use the lab files under `models/` when the decision depends on family-specific tradeoffs rather than broad routing.
- Treat vendor-published numbers as operational guidance. Approximate or release-sensitive values should be re-checked before production commitments.

## Boundaries

- Model-family selection lives here and in `models/`.
- Architecture mechanics stay in `../../model-architectures/references/` and `../../cutting-edge-architectures/references/`.
- Serving backends, hardware planning, and environment details stay in the specialist shared references and skills.

## File Map

| Family / Scope | Detailed Reference | Notes |
| -------------- | ------------------ | ----- |
| Mistral, Mixtral, Ministral, Devstral | [models/mistral.md](models/mistral.md) | Dense + MoE + code models |
| DeepSeek V3.2, R1, distills, OCR | [models/deepseek.md](models/deepseek.md) | Frontier MoE + reasoning + OCR |
| Kimi K2, K2-Mini, K2.5 | [models/kimi.md](models/kimi.md) | Large multimodal agentic MoE |
| GLM-4, GLM-4.7-Flash, GLM-5 | [models/glm.md](models/glm.md) | Multilingual tool-use + large MoE |
| Qwen3, Qwen3.5, Qwen3-Coder-Next | [models/qwen.md](models/qwen.md) | Broad model line, strong coding + agents |
| Nemotron 3 and Nemotron-Cascade | [models/nemotron.md](models/nemotron.md) | Long-context MoE + Cascade RL reasoning |
| Gemma 4, TranslateGemma | [models/gemma.md](models/gemma.md) | Apache 2.0 multimodal + translation |
| MiniMax M2.5, M2.7 | [models/minimax.md](models/minimax.md) | Code and agentic focus |
| Olmo 3, Olmo 3.1 | [models/olmo.md](models/olmo.md) | Fully open weights + data + code |
| Liquid AI LFM | [models/liquid.md](models/liquid.md) | Edge and hybrid reasoning |
| Recent additions under 6 months | [models/emerging-models.md](models/emerging-models.md) | Trinity, Tiny Aya, Sarvam, MiMo-V2-Pro |
| Low-VRAM and edge routing | [models/edge-small.md](models/edge-small.md) | Selection guide only |

## Quick Selection Matrix

| Need | Recommended Starting Point | Why |
| ---- | -------------------------- | --- |
| General on-prem workhorse | Ministral 3 8B / Gemma 4 31B / GLM-4.7-Flash | Strong balance of quality, tooling, and deployability |
| Code agent on 1-2 GPUs | Devstral Small 2 / Qwen3-Coder-Next / DeepSeek-R1 distill | Best tradeoff for SWE-style workflows |
| Reasoning under 80 GB | Olmo 3.1 Think 32B / Nemotron-Cascade-2-30B-A3B / DeepSeek-R1 distill 32B | High reasoning density without frontier cluster requirements |
| Frontier open-weight MoE | DeepSeek V3.2 / Qwen3.5 397B-A17B / Kimi K2.5 / GLM-5 | Highest capability tier, cluster-oriented |
| Translation | TranslateGemma | Dedicated translation family, better than repurposing a general LLM |
| OCR and document ingestion | DeepSeek-OCR | Purpose-built OCR -> Markdown / structured text path |
| Full transparency and auditability | Olmo 3 / 3.1 | Strongest fully open option in this landscape |
| Edge / on-device reasoning | LFM2.5-1.2B-Thinking / Gemma 4 E2B-E4B / Ministral 3 3B / Tiny Aya | Good fit for low-VRAM or offline use |
| Multimodal agentic workflows | Kimi K2.5 / Gemma 4 / Qwen3.5 Omni | Strong tool-use + multimodal positioning |

## Consolidated Family Snapshot

| Family | Architecture Style | Typical Active Params | Context | License Posture | Detailed Ref |
| ------ | ------------------ | --------------------- | ------- | --------------- | ------------ |
| Mistral / Mixtral / Ministral | Dense + sparse MoE | 3B to 41B active | Up to 256k | Mostly Apache 2.0 | [models/mistral.md](models/mistral.md) |
| DeepSeek | Frontier MoE + RL reasoning | Distills to ~37B active frontier | ~164k on V3.2 line | Open-weight, verify per model card | [models/deepseek.md](models/deepseek.md) |
| Kimi | Very large MoE + multimodal | 32B active on K2 | Up to 256k | Open-weight / permissive, verify exact terms | [models/kimi.md](models/kimi.md) |
| GLM | Dense + MoE multilingual | ~3B active on GLM-4.7-Flash, 40B active on GLM-5 | 200k to 1M | Open-weight, generally deployable | [models/glm.md](models/glm.md) |
| Qwen | Broad dense + MoE family | 3B to 22B / 17B active on large MoE | 32k to 128k+ | Apache 2.0 on many 3.5 releases; verify checkpoint terms | [models/qwen.md](models/qwen.md) |
| Nemotron | MoE + Cascade RL | 3B to 50B active | Up to 1M | Open weights + recipes in NVIDIA ecosystem | [models/nemotron.md](models/nemotron.md) |
| Gemma | Dense + MoE multimodal | 2B to 31B / 26B MoE | Up to 256k | Apache 2.0 | [models/gemma.md](models/gemma.md) |
| MiniMax | Large code/agent MoE | ~10B active on M2.5 | ~200k | Open-weight, verify exact release terms | [models/minimax.md](models/minimax.md) |
| Olmo | Dense, fully open | 7B to 32B | ~65k | Fully open weights + data + code | [models/olmo.md](models/olmo.md) |
| Liquid | Hybrid non-GPT | ~1.2B in edge reasoning variant | 32k | Open-weight | [models/liquid.md](models/liquid.md) |
| Emerging | Mixed | 1B to 13B active or more | Varies | Mixed | [models/emerging-models.md](models/emerging-models.md) |

## Hardware Sizing Guide

| Deployment Envelope | Good Candidates | Notes |
| ------------------- | --------------- | ----- |
| CPU / mobile / very low VRAM | LFM2.5-1.2B-Thinking, Ministral 3 3B, Tiny Aya | Prefer GGUF / low-bit quantization |
| 1 x 16-24 GB GPU | Ministral 3 8B, DeepSeek-R1 distill 7B-14B, TranslateGemma 12B, Olmo 3 7B | Best local productivity tier |
| 1 x 48-80 GB GPU | Gemma 4 31B, Olmo 3.1 32B, GLM-4.7-Flash, Nemotron-3-Nano-30B-A3B, Devstral Small 2 | Strong single-node tier |
| 2-4 x 80 GB GPUs | MiniMax M2.5 quantized, Qwen3-Coder-Next, some mid-size MoE with quantization/offload | Good for code-heavy internal platforms |
| 8 x H100/H200 class | Mistral Large 3, Nemotron Super, some Qwen3.5 and DeepSeek frontier serving configurations | Datacenter / rack deployment |
| Multi-node cluster | DeepSeek V3.2, Kimi K2.5, GLM-5, Qwen3.5 397B-A17B, Trinity Large | Use expert parallel + tensor/pipeline parallel as needed |

For routing and expert parallel details, see `../cutting-edge-architectures/references/moe-sparse-routing.md`.

## Use-Case Routing

### Code and software engineering

- Devstral 2 / Small 2
- Qwen3-Coder-Next
- MiniMax M2.5 / M2.7
- Nemotron-Cascade-2-30B-A3B
- DeepSeek-R1 distills

### General reasoning

- Olmo 3.1 Think 32B
- Nemotron-Cascade-2-30B-A3B
- DeepSeek-R1 distills
- Ministral 3 14B Reasoning
- Qwen3.5 14B-32B and larger MoE line

### Translation and document pipelines

- TranslateGemma
- DeepSeek-OCR
- Pair with a reasoning model for downstream synthesis

### Frontier MoE labs

- DeepSeek V3.2
- Kimi K2.5
- GLM-5
- Qwen3.5 397B-A17B
- Trinity Large

### Edge and low-VRAM deployment

- See [models/edge-small.md](models/edge-small.md)

## License Summary

| License Posture | Families |
| --------------- | -------- |
| Apache 2.0 or clearly permissive | Ministral / parts of Mistral line, Gemma 4, many Qwen releases, Tiny Aya, Trinity |
| Fully open weights + data + code | Olmo 3 / 3.1 |
| Open-weight but verify exact terms per release | DeepSeek, Kimi, MiniMax, some NVIDIA and Z.ai releases |
| Mixed within same family | Mistral line (Devstral 2 vs Devstral Small 2), Gemma-derived translation, emerging models |

Always verify the model card before deployment in regulated or commercial settings.

## Cross-References

- Architecture families: `../../model-architectures/references/architecture-catalog.md`
- MoE systems and expert parallelism: `../../cutting-edge-architectures/references/moe-sparse-routing.md`
- Attention and efficiency mechanisms: `../../cutting-edge-architectures/references/attention-innovations.md`
- Serving frameworks: `../../model-inference/references/serving-frameworks.md`
- GPU sizing workflow: `../../gpu-compute/SKILL.md`
