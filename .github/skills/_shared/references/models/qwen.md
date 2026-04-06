# Qwen Family

Includes Qwen3, Qwen3.5, Qwen3-Coder-Next, and adjacent specialist releases in the Qwen ecosystem.

## Variant Snapshot

| Model | Style | Total / Active Params | Context | Primary Use | Notes |
| ----- | ----- | --------------------- | ------- | ----------- | ----- |
| Qwen3 flagship | Sparse MoE | 235B / 22B active | 32k to 128k+ | General + reasoning + tool-use | Broad multilingual line |
| Qwen3 smaller variants | Dense / smaller | 7B / 14B / 32B | Varies | Local inference | Strong local ecosystem |
| Qwen3.5 flagship | Sparse MoE | 397B / 17B active | Large context | Native multimodal agents | Apache 2.0 on many releases; verify exact card per checkpoint |
| Qwen3.5 mid-size | Dense / MoE smaller | 7B / 14B / 32B / 122B | Varies | On-prem reasoning and agents | Good practical deployment range |
| Qwen3-Coder-Next | Sparse MoE code model | 80B / 3B active | Local long-context code | Coding agents | High-value specialist model |
| Qwen3-Guard | Safety model | N/A | N/A | Guardrails and safety | Mentioned as adjacent specialized release |

## Architecture and Innovations

- Qwen3 is described as hybrid reasoning with broad multilingual and multimodal capabilities.
- Qwen3.5 pushes toward native multimodal agents with hybrid linear attention and sparse MoE.
- Qwen3-Coder-Next matters operationally because it gives a strong code-agent profile without the full cost of the largest Qwen line.

Cross-references:

- Architecture families: `../../model-architectures/references/architecture-catalog.md`
- MoE serving and expert slicing: `../../cutting-edge-architectures/references/moe-sparse-routing.md`

## Training and Post-Training Notes

- Qwen3.5 uses large-scale RL on agentic environments.
- Qwen is one of the broadest open-weight ecosystems, with coder, guard, VL, and omni variants.

## Inference and Deployment Profiles

| Deployment Profile | Good Candidates | Notes |
| ------------------ | --------------- | ----- |
| 1 x 24-48 GB GPU | Qwen3.5 7B / 14B / 32B, Qwen3-Coder-Next quantized | Strong local stack |
| 1 x 48-80 GB GPU | Qwen 32B-class and code variants | Good internal productivity tier |
| Multi-GPU node | Qwen3 flagship, Qwen3.5 122B | Advanced on-prem deployment |
| Cluster | Qwen3.5 397B-A17B | Frontier class |

Serving notes:

- Qwen integrates well with Transformers, vLLM, llama.cpp, and the Qwen-Agent tooling ecosystem.
- Qwen3-Coder-Next is one of the clearest paths to local coding agents in the current open-weight landscape.

## Strengths and Positioning

| Model | Strength |
| ----- | ----------------- |
| Qwen3 | Top-tier open-weight reasoning, coding, and tool-use in 2025 |
| Qwen3.5 | Matches or exceeds GPT-4o / GPT-5-mini on some published code and reasoning benchmarks |
| Qwen3-Coder-Next | Around 44.3% SWE-Bench Pro |

## Repos and Weights

- Research portal: <https://qwen.ai/research>
- GitHub org: <https://github.com/QwenLM>
- Qwen3 repo: <https://github.com/QwenLM/qwen3>
- Qwen3-Coder repo: <https://github.com/QwenLM/Qwen3-Coder>
- Qwen3.5 repo: <https://github.com/QwenLM/Qwen3.5>

## Sources

- <https://notegpt.io/blog/introducing-qwen3>
- <https://huggingface.co/blog/daya-shankar/open-source-llms>
- <https://qwen.ai/research>
- <https://dev.to/vishva_ram/qwen-3-the-open-source-llm-changing-ai-for-developers-1hig>
- <https://dev.to/sienna/qwen3-coder-next-the-complete-2026-guide-to-running-powerful-ai-coding-agents-locally-1k95>
- <https://github.com/QwenLM>
