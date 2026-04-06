# GLM Family

Includes GLM-4, GLM-4-Flash, GLM-4.7-Flash, and GLM-5 from Z.ai / Zhipu AI.

## Variant Snapshot

| Model | Style | Total / Active Params | Context | Primary Use | Notes |
| ----- | ----- | --------------------- | ------- | ----------- | ----- |
| GLM-4 | Dense family | Varies | Long context variants | General multilingual use | ChatGLM descendant line |
| GLM-4-Flash | Optimized dense / efficient line | Varies | 128k+ | Tool-use and latency | Efficient deployment path |
| GLM-4.7-Flash | Sparse MoE | 30B / ~3B active | 200k+ | Strong 30B-class tool-use model | Good local datacenter fit |
| GLM-5 | Large sparse MoE | ~744B / 40B active | Very long context | Agentic large-scale workflows | Frontier tier |

## Architecture and Innovations

- GLM-4.x highlights multilingual tool use with GQA, 2D RoPE, RMSNorm, and efficient transformer choices.
- GLM-4.7-Flash is the deployable sweet spot in this family: a 30B-A3B MoE tuned for practical local serving.
- GLM-5 moves into frontier agentic MoE territory alongside Qwen3.5 and Kimi K2.5.

Cross-references:

- Modern attention patterns: `../../model-architectures/references/attention-mechanisms.md`
- MoE scaling and expert-parallel serving: `../../cutting-edge-architectures/references/moe-sparse-routing.md`

## Training and Post-Training Notes

- The GLM line emphasizes multilingual tool-use and agentic positioning.
- GLM-5 is framed as a major February 2026 MoE release for more complex, long-duration tasks.

## Inference and Deployment Profiles

| Deployment Profile | Good Candidates | Notes |
| ------------------ | --------------- | ----- |
| 1 x 24-48 GB GPU | GLM-4.7-Flash quantized | Strong local agent / RAG candidate |
| 1 x 48-80 GB GPU | GLM-4.7-Flash full or lightly quantized | Best single-node target in the family |
| Cluster / API | GLM-5 | Frontier-scale serving |

Serving notes:

- GLM-4.7-Flash is the most actionable entry for on-prem deployments.
- Referenced deployment guides cite vLLM, SGLang, llama.cpp, LM Studio, and Ollama integration paths.

## Strengths and Positioning

| Model | Strength |
| ----- | ----------------- |
| GLM-4.x / 4.7-Flash | Competitive on coding and tool use, especially Chinese/English workloads |
| GLM-4.7-Flash | Strong 30B-class option for local agentic serving |
| GLM-5 | Frontier large-capacity agentic MoE line |

## Repos and Weights

- Developer docs: <https://docs.z.ai/guides/llm/glm-4.7>
- HF weights: <https://huggingface.co/zai-org/GLM-4.7-Flash>
- Local guide: <https://unsloth.ai/docs/models/glm-4.7-flash>
- LM Studio: <https://lmstudio.ai/models/glm-4.7>
- Ollama: <https://ollama.com/library/glm-4.7-flash>

## Sources

- <https://www.emergentmind.com/topics/glm-4-flash-model>
- <https://docs.z.ai/guides/llm/glm-4.7>
- <https://huggingface.co/zai-org/GLM-4.7-Flash>
- <https://unsloth.ai/docs/models/glm-4.7-flash>
- <https://lmstudio.ai/models/glm-4.7>
