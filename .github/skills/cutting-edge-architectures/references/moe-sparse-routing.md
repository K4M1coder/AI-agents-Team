# Mixture of Experts (MoE) & Sparse MoE (SMoE) — System Reference

Comprehensive reference for sparse expert routing, system stacks, training patterns, inference patterns, and expert parallelism. Covers 2024–2026 SOTA surveys, frameworks, and adoption guidance.

> Cross-reference: architecture design parameters (num experts, top-k, load balance) in `skills/model-architectures/references/architecture-catalog.md`.  
> Cross-reference: HC/mHC residual topology impact on MoE training stability in `references/residual-innovations.md`.

---

## SMoE vs Dense MoE

| Aspect | Dense MoE | Sparse MoE (SMoE) |
| -------- | ----------- | -------------------- |
| Expert activation | All experts per token | Top-k experts per token (k << N) |
| Compute per token | O(N × d) | O(k × d), sublinear in total params |
| Routing | None (all active) | Learned gating function (softmax router) |
| Training signal | All experts receive gradients | Only routed experts receive gradients |
| Load balance | N/A | Critical — requires auxiliary loss or regularization |
| Scaling advantage | Linear compute growth | Sublinear — increase params without proportional compute |
| Key challenge | Compute cost | Expert collapse, routing instability, load imbalance |

In practice, almost all modern MoE architectures are **sparse** (SMoE). Dense MoE is used in the literature primarily as a theoretical baseline.

---

## Routing Mechanisms

### Top-k Gating

Standard softmax router selects top-k experts per token:

$$G(x) = \text{TopK}(\text{softmax}(W_g \cdot x + \epsilon), k)$$

Where $\epsilon$ is optional noise for exploration (Noisy Top-k) and $W_g \in \mathbb{R}^{N \times d}$ is the router weight matrix.

| Routing Strategy | k | Models | Trade-off |
| ------------------ | --- | -------- | ----------- |
| **Top-1** | 1 | Switch Transformer | Minimum compute, harder to balance |
| **Top-2** | 2 | Mixtral 8×7B, GShard | Good balance between compute and diversity |
| **Fine-grained** | 8 of 256 | DeepSeekMoE | Many small experts, fine-grained specialization |

### Capacity Factor

Limits how many tokens each expert can process per batch:

$$\text{Expert buffer size} = \text{capacity\_factor} \times \frac{N_{\text{tokens}}}{N_{\text{experts}}}$$

- `capacity_factor = 1.0`: Perfectly balanced (tokens dropped if exceeded)
- `capacity_factor = 1.25`: 25% headroom (recommended in practice)
- `capacity_factor > 2.0`: Rarely useful — wastes memory

### Unified Competitive Learning (arxiv:2503.22996)

Reframes expert routing as a **linear programming (LP)** problem. Unifies auxiliary loss, entropy regularization, and variational constraints under a single competitive learning formulation. Key insight: optimal routing emerges from a unified scoring function rather than ad-hoc regularization terms.

---

## Expert Collapse Prevention

Expert collapse occurs when the router converges to routing most tokens to a few experts, leaving others underutilized.

| Method | Mechanism | Paper |
| -------- | ----------- | ------- |
| **Auxiliary load-balance loss** | Penalizes uneven expert utilization | Switch Transformer |
| **Entropy regularization** | Encourages uniform routing probability | GShard |
| **Variational constraints** | Probabilistic routing with KL regularization | arxiv:2503.22996 |
| **Auxiliary-loss-free** | Expert isolation loss + fine-grained segmentation | DeepSeekMoE (arxiv:2405.04434) |
| **Expert choice routing** | Expert selects tokens (not vice versa) | Zhou et al. 2022 |
| **LP formulation** | Unified competitive learning framework | arxiv:2503.22996 |

DeepSeek's auxiliary-loss-free approach segments each standard expert into many fine-grained sub-experts (e.g. 256), activating a subset (e.g. 8). This fine-grained segmentation + expert isolation loss prevents collapse without explicit load-balance auxiliary loss.

---

## System Stacks

### DeepSpeed-MoE

Microsoft Research framework for efficient MoE training and inference.

**API**:

```python
import deepspeed
from deepspeed.moe.layer import MoE

moe_layer = MoE(
    hidden_size=d_model,
    expert=ExpertFFN(d_model, d_ff),
    num_experts=num_experts,
    ep_size=ep_size,           # expert parallelism degree
    k=top_k,                   # experts per token
    capacity_factor=1.25,
    use_residual=True,         # shared expert residual
    noisy_gate_policy="RSample"
)
```

**Performance** (from DeepSpeed-MoE paper):

- 7.3× inference latency improvement over dense equivalent
- Up to 9× cost reduction for equivalent quality
- Expert slicing: when #GPUs > #experts, slice experts across GPUs for tensor-parallel within each expert

**Expert Parallelism Config**:

```json
{
  "moe": {
    "enabled": true,
    "ep_size": 8,
    "num_experts": 64,
    "top_k": 2,
    "capacity_factor": 1.25,
    "min_capacity": 4,
    "noisy_gate_policy": "RSample"
  }
}
```

### Tutel (Microsoft)

High-performance MoE dispatch library. Architecture-agnostic — works as a drop-in layer.

| Feature | Detail |
| --------- | -------- |
| Backend | CUDA, ROCm (AMD) |
| Precision | FP32, FP16, BF16, FP8, FP4 |
| Parallel modes | Expert parallel, data parallel, pipeline parallel — **no-penalty combination** |
| All-to-all | Optimized NCCL/RCCL dispatch with overlap |
| Repository | [microsoft/Tutel](https://github.com/microsoft/tutel) |

### X-MoE (DeepSpeed extension)

Extension for AMD MI250X/MI300X GPU support:

- < 10% TFLOPS overhead vs theoretical peak on MI250X
- Custom RCCL all-to-all kernels for expert dispatch
- arxiv:2508.13337

---

## Expert Parallelism

Expert parallelism (EP) distributes experts across devices. Combined with data parallelism (DP) and tensor parallelism (TP) for "3D" or "4D" parallelism.

### Parallelism Topology

```text
┌─────────────────────────────────────────────────────────┐
│                    Pipeline Parallel (PP)                │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────┐ │
│  │   Stage 0      │  │   Stage 1      │  │  Stage 2   │ │
│  │  ┌──────────┐  │  │  ┌──────────┐  │  │            │ │
│  │  │ Expert   │  │  │  │ Expert   │  │  │   Dense    │ │
│  │  │ Parallel │  │  │  │ Parallel │  │  │   Layers   │ │
│  │  │ (EP)     │  │  │  │ (EP)     │  │  │            │ │
│  │  └──────────┘  │  │  └──────────┘  │  │            │ │
│  │  ┌──────────┐  │  │  ┌──────────┐  │  │            │ │
│  │  │ Tensor   │  │  │  │ Tensor   │  │  │            │ │
│  │  │ Parallel │  │  │  │ Parallel │  │  │            │ │
│  │  │ (TP)     │  │  │  │ (TP)     │  │  │            │ │
│  │  └──────────┘  │  │  └──────────┘  │  │            │ │
│  └────────────────┘  └────────────────┘  └────────────┘ │
│         Data Parallel (DP) across replicas               │
└─────────────────────────────────────────────────────────┘
```

### EP Sizing Guide

| Experts | GPUs per node | Recommended EP | Notes |
| --------- | -------------- | --------------- | ------- |
| 8 | 8 | ep_size=8 | 1 expert per GPU |
| 16 | 8 | ep_size=8 | 2 experts per GPU |
| 64 | 8 | ep_size=8 | 8 experts per GPU — capacity limited |
| 64 | 8×8 nodes | ep_size=64 | 1 expert per GPU, cross-node all-to-all |
| 256 | 8×8 nodes | ep_size=64 | 4 fine-grained experts per GPU |

**Communication**: Expert dispatch requires **all-to-all** collective (NCCL/RCCL). Performance depends on:

- Intra-node: NVLink/NVSwitch (900 GB/s on H100 SXM)
- Inter-node: InfiniBand NDR (400 Gbps) — cross-node EP adds latency
- Expert slicing: When #GPUs > #experts, experts are tensor-parallelized across GPUs

---

## Notable SMoE Models

| Model | Total Params | Active Params | Top-k | Experts | Key Innovation |
| ------- | ------------- | -------------- | ------- | --------- | --------------- |
| **Mixtral 8×7B** | 46.7B | ~12.9B | 2 | 8 | Sliding window attention + SMoE, open-weights (arxiv:2401.04088) |
| **Switch Transformer** | 1.6T | ~1/128th | 1 | 128-2048 | Top-1 simplified routing, massive scale |
| **DeepSeekMoE** (V2) | 236B | 21B | 8/256 | 256 fine-grained | Auxiliary-loss-free, fine-grained experts, combined with MLA |
| **DeepSeek-V3** | 671B | 37B | 8/256 | 256 fine-grained | FP8 training, MLA + MoE, auxiliary-loss-free |
| **GShard** | 600B | ~1/64th | 2 | 64 | Expert capacity, random routing for overflow |
| **Grok-1** (xAI) | 314B | ~73B | 2 | 8 | Largest open-weights MoE at release |

---

## Multi-Domain SMoE (NMT Reference)

Sparse MoE applied to Neural Machine Translation (NMT) for multi-domain specialization (arxiv:2407.01126):

- Each expert specializes in a language pair or domain
- Routing learns domain-specific paths without explicit domain labels
- Demonstrates SMoE advantage beyond LLM: domain-conditional computation

---

## MoE Inference Patterns

### Expert Slicing for Inference

When serving MoE models, expert slicing distributes experts across GPUs:

```text
equest → Router → Expert Dispatch (all-to-all) → Expert Compute → Gather → Output
```

**DeepSpeed-Inference MoE mode:**

- Automatic expert placement across available GPUs
- Process-group-based all-to-all for token routing
- Compatible with tensor parallelism within experts

### Inference Considerations

| Aspect | Dense Model | MoE Model |
| -------- | ------------- | ----------- |
| Memory | All params loaded | All params loaded (total > active) |
| FLOPS/token | All params compute | Only top-k experts compute |
| Latency | Predictable | Router + dispatch overhead |
| Batching | Standard | Token-level routing diversity |
| GPU memory | `params × precision` | Same — all experts in memory |
| Throughput advantage | None | Higher tokens/sec for same FLOPS budget |

Key insight: MoE models have **same memory footprint** as dense equivalent (all experts loaded) but **lower compute per token** (only k of N active). Memory is the bottleneck, not compute.

---

## 2025–2026 Surveys

| Survey | Year | Scope | Key Contributions |
| -------- | ------ | ------- | ------------------- |
| arxiv:2507.11181 | 2025 | MoE for LLMs | Comprehensive taxonomy of routing, training, scaling |
| arxiv:2602.08019 | 2026 | SMoE algorithmic + systems | Deep-dives into system-level optimizations (EP, all-to-all, capacity) |
| arxiv:2503.22996 | 2025 | Unified Competitive Learning | LP formulation unifying load balance approaches |
| arxiv:2401.04088 | 2024 | Mixtral 8×7B | Open-weights reference SMoE architecture + evaluation |

---

## Adoption Decision Guide

```text
Need sublinear compute scaling?
  YES → SMoE
    ├── Easy start: Mixtral 8×7B (open-weights, well-documented, top-2, 8 experts)
    ├── Maximum efficiency: DeepSeekMoE pattern (256 fine-grained, auxiliary-loss-free)
    ├── Training framework: DeepSpeed-MoE (best documented) or Tutel (best AMD support)
    ├── Expert collapse: Start with auxiliary loss weight 0.01, eval distribution, adjust
    ├── Expert parallelism: ep_size = min(#experts, #GPUs), NVLink intra-node preferred
    ├── Inference: DeepSpeed-Inference MoE mode or custom expert slicing
    └── AMD GPUs: X-MoE extension (<10% TFLOPS overhead on MI250X)
  NO → Dense model (simpler, no routing overhead)
```

---

## Resource Table

| Resource | Type | URL |
| ---------- | ------ | ----- |
| Survey: MoE for LLMs (2025) | Paper summary | [tldr.takara.ai/2507.11181](https://tldr.takara.ai/arxiv/2507.11181) |
| Survey: SMoE Algo + Systems (2026) | Paper summary | [tldr.takara.ai/2602.08019](https://tldr.takara.ai/arxiv/2602.08019) |
| Unified Competitive Learning (2025) | Paper summary | [tldr.takara.ai/2503.22996](https://tldr.takara.ai/arxiv/2503.22996) |
| Mixtral 8×7B (2024) | Paper analysis | [emergentmind.com/2401.04088](https://www.emergentmind.com/papers/2401.04088) |
| SMoE Topic Overview | Topic hub | [emergentmind.com/topics/smoe](https://www.emergentmind.com/topics/sparse-mixture-of-experts) |
| Multi-domain NMT SMoE | Paper | [arxiv:2407.01126](https://arxiv.org/abs/2407.01126) |
| X-MoE AMD Extension | Paper | [arxiv:2508.13337](https://arxiv.org/abs/2508.13337) |
| Tutel (Microsoft) | Code | [github.com/microsoft/tutel](https://github.com/microsoft/tutel) |
| DeepSpeed-MoE Paper | Paper (PDF) | [experts.illinois.edu — DeepSpeed-MoE](https://experts.illinois.edu/en/publications/deepspeed-moe-advancing-mixture-of-experts-inference-and-training) |
| DeepSpeed-MoE Training Tutorial | Tutorial | [deepspeed.readthedocs.io — MoE](https://www.deepspeed.ai/tutorials/mixture-of-experts/) |
| DeepSpeed-MoE Inference Tutorial | Tutorial | [deepspeed.readthedocs.io — MoE Inference](https://www.deepspeed.ai/tutorials/mixture-of-experts-inference/) |
| Performance analysis (ACM) | Conference Paper | [dl.acm.org/3712285.3759886](https://dl.acm.org/doi/10.1145/3712285.3759886) |
| OPECST AI Report (FR Senate) | Government report | [senat.fr — OPECST IA](https://www.senat.fr/rap/r24-235/r24-235-syn.html) |
| MoE Architecture Explained | Blog | [sushant-kumar.com/moe](https://www.sushant-kumar.com/blog/mixture-of-experts) |
| Mixtral emergentmind overview | Topic hub | [emergentmind.com/Mixtral](https://www.emergentmind.com/topics/mixtral) |
