# DeepSeek Family

Includes DeepSeek V3 / V3.2, DeepSeek-R1, R1 distills, and DeepSeek-OCR.

## Variant Snapshot

| Model | Style | Total / Active Params | Context | Primary Use | Notes |
| ----- | ----- | --------------------- | ------- | ----------- | ----- |
| DeepSeek V3 / V3.2 | Frontier sparse MoE | Large frontier scale, approx. 37B active on the major line | ~164k on V3.2 line | General + reasoning + code | Standard / Exp / Speciale variants |
| DeepSeek-R1 | RL reasoning model | Built on V3 base | Large frontier | Reasoning | Open-weight reasoning flagship |
| R1 distills | Distilled reasoning models | 1.5B to 70B range | Varies | Local reasoning / code | Based on Qwen and Llama derivatives |
| DeepSeek-OCR | Vision-text transformer | N/A | Image -> text pipeline | OCR, document ingestion | Complements DeepSeek reasoning stack |

## Architecture and Innovations

- DeepSeek V3.2 is presented as a large MoE line with DeepSeek Sparse Attention for long-context efficiency.
- DeepSeek-R1 emphasizes RL-first reasoning rather than a standard SFT-centric path.
- The R1 distill line matters more operationally than the frontier model for many internal deployments.
- DeepSeek-OCR extends the DeepSeek ecosystem into document ingestion and structured extraction.

Cross-references:

- MoE system details: `../../cutting-edge-architectures/references/moe-sparse-routing.md`
- MLA and efficiency techniques: `../../cutting-edge-architectures/references/attention-innovations.md`

## Training and Post-Training Notes

- DeepSeek-R1 is described as a reasoning model trained through large-scale reinforcement learning over a V3 base.
- The R1 line follows a path from V3 pretraining to RL, with a readability-oriented cold-start phase before further RL polishing.
- Distilled R1 variants provide a practical path to local reasoning deployments without frontier infrastructure.

## Inference and Deployment Profiles

| Deployment Profile | Good Candidates | Notes |
| ------------------ | --------------- | ----- |
| 1 x 16-24 GB GPU | DeepSeek-R1 distill 7B / 14B | Best local reasoning entry points |
| 1 x 48-80 GB GPU | Distill 32B / some OCR workflows | Good reasoning density when quantized |
| Multi-GPU node | DeepSeek-OCR + reasoning stack | Useful for document pipelines |
| Cluster / API proxy | DeepSeek V3.2 complete line | Frontier serving tier |

Serving notes:

- R1 distills are the practical on-prem recommendation for math/code-heavy reasoning.
- The full V3.2 line is mostly cluster-scale or API-consumption territory.
- DeepSeek-OCR is useful as a front-end model in OCR -> Markdown -> reasoning pipelines.

## Strengths and Positioning

| Model | Strength |
| ----- | ----------------- |
| DeepSeek-R1 | AIME 2024 79.8%, MATH-500 97.3%, Codeforces Elo 2029, SWE-Bench Verified 49.2%, MMLU 90.8% |
| DeepSeek-R1 distills | Best local open-weight reasoning options in the 7B-32B band |
| DeepSeek V3.2 | Frontier open-weight reference for MoE reasoning and code |
| DeepSeek-OCR | Outperforms TrOCR and Donut on cited OCR evaluations; about 2,500 tok/s in OCR -> text pipelines |

## Repos and Weights

- Organization: <https://github.com/deepseek-ai>
- R1 repo: <https://github.com/deepseek-ai/deepseek-r1>
- R1 model card: <https://huggingface.co/deepseek-ai/DeepSeek-R1>
- Open R1 reproduction: <https://github.com/huggingface/open-r1>

## Sources

- <https://siyaz.com.tr/en/blog/deepseek-r1-open-source-reasoning>
- <https://huggingface.co/deepseek-ai/DeepSeek-R1>
- <https://github.com/deepseek-ai/deepseek-r1>
- <https://www.modelmath.app/models/deepseek/deepseek-v3.2-speciale>
- <https://haimaker.ai/models/deepseek/deepseek-v3.2-exp>
- <https://holisticrm.com/deepseek-ocr-new-open-source-ai-model-goes-viral-on-github-dataconomy/>
- <https://www.linkedin.com/posts/andrepiper_github-deepseek-aideepseek-ocr-contexts-activity-7386027419188543489-BtQB>
