# Nemotron Family

Includes Nemotron 3 Nano / Super / Ultra, Nemotron-Cascade, and Nemotron-Cascade 2.

## Variant Snapshot

| Model | Style | Total / Active Params | Context | Primary Use | Notes |
| ----- | ----- | --------------------- | ------- | ----------- | ----- |
| Nemotron-3-Nano-30B-A3B | MoE | 30B / ~3.5B active | 1M | Coding, reasoning, tool calling | Best local entry in family |
| Nemotron-3-Super-120B-A12B | MoE | 120B / 12B active | 1M | Heavy agentic workflows | Datacenter class |
| Nemotron-3-Ultra | MoE | ~500B / 50B active | Long context | Frontier reasoning | Largest public family member |
| Nemotron-Cascade-14B-Thinking | RL reasoning | 14B | N/A | Small reasoning specialist | Beats larger baselines on some tasks |
| Nemotron-Cascade-2-30B-A3B | MoE + Cascade RL | 30B / 3B active | 1M | Local reasoning / math / code | High reasoning density |

## Architecture and Innovations

- Nemotron 3 combines LatentMoE Mamba-2 + Attention with long-context positioning.
- NVIDIA emphasizes NVFP4-era training efficiency and open recipes in the NeMo ecosystem.
- Nemotron-Cascade applies Cascade RL on top of SFT bases to push reasoning performance sharply upward.

Cross-references:

- MoE and expert parallel details: `../../cutting-edge-architectures/references/moe-sparse-routing.md`
- Architecture families: `../../model-architectures/references/architecture-catalog.md`

## Training and Post-Training Notes

- Nemotron 3 uses multi-environment RL and NeMo Gym / NeMo RL tooling in NVIDIA's open stack.
- Cascade 2 adds multi-domain on-policy distillation over the Nemotron-3-Nano base.

## Inference and Deployment Profiles

| Deployment Profile | Good Candidates | Notes |
| ------------------ | --------------- | ----- |
| 1 x 48-80 GB GPU | Nemotron-3-Nano-30B-A3B, Nemotron-Cascade-2-30B-A3B | Excellent local reasoning + code tier |
| 8 x 80 GB GPUs | Nemotron-3-Super-120B-A12B | Practical minimum for Super deployments |
| Cluster / DGX tier | Nemotron Ultra | Frontier deployment |

Serving notes:

- Cascade 2 is one of the best reasoning-dense models in the current open-weight landscape.
- Nano 30B-A3B is a strong practical target for large-context on-prem deployments.

## Strengths and Positioning

| Model | Strength |
| ----- | ----------------- |
| Nemotron-Cascade-14B-Thinking | Stronger than DeepSeek-R1-0528 on LiveCodeBench v5/v6 in cited evaluations |
| Nemotron-Cascade-2-30B-A3B | Gold-level results on IMO 2025, IOI 2025, and ICPC 2025 in cited reports |
| Nemotron-3-Nano-30B-A3B | Strong 30B-class open-weight candidate with 1M context |

## Repos and Weights

- NVIDIA announcement: <https://nvidianews.nvidia.com/news/nvidia-debuts-nemotron-3-family-of-open-models>
- Nano card: <https://build.nvidia.com/nvidia/nemotron-3-nano-30b-a3b/modelcard>
- Super card: <https://build.nvidia.com/nvidia/nemotron-3-super-120b-a12b/modelcard>
- Cascade page: <https://research.nvidia.com/labs/nemotron/nemotron-cascade/>
- Cascade 2: <https://research.nvidia.com/labs/nemotron/nemotron-cascade-2/>
- HF Cascade 2: <https://huggingface.co/nvidia/Nemotron-Cascade-2-30B-A3B>

## Sources

- <https://nvidianews.nvidia.com/news/nvidia-debuts-nemotron-3-family-of-open-models>
- <https://build.nvidia.com/nvidia/nemotron-3-nano-30b-a3b/modelcard>
- <https://build.nvidia.com/nvidia/nemotron-3-super-120b-a12b/modelcard>
- <https://research.nvidia.com/labs/nemotron/nemotron-cascade/>
- <https://research.nvidia.com/labs/nemotron/nemotron-cascade-2/>
- <https://huggingface.co/nvidia/Nemotron-Cascade-2-30B-A3B>
- <https://venturebeat.com/orchestration/nvidias-nemotron-cascade-2-wins-math-and-coding-gold-medals-with-3b-active/>
