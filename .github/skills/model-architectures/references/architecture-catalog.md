# Architecture Catalog

Comprehensive reference of ML architecture families with design parameters and trade-offs.

## Transformer Variants

### Standard Transformer (Vaswani et al., 2017)

- **Layers**: Encoder + Decoder with cross-attention
- **Attention**: Multi-Head Attention (MHA), O(n²) in sequence length
- **Position**: Sinusoidal or learned positional embeddings
- **Norm**: LayerNorm (post-norm originally, pre-norm preferred now)
- **FFN**: 2-layer MLP with ReLU/GELU

### Modern Decoder-Only (GPT/Llama/Moshi pattern)

- **Attention**: GQA or MQA for efficient KV cache
- **Position**: RoPE (used in Moshi, Llama) — no maximum length limit
- **Norm**: RMSNorm (pre-norm) — faster than LayerNorm
- **FFN**: SwiGLU activation — better than GELU empirically
- **KV Cache**: For autoregressive generation efficiency
- **Scaling**: Width (d_model) and depth (n_layers) scale together

### Moshi Architecture (Kyutai, arxiv:2410.00037)

- **Temporal Transformer**: 7B params, processes multi-stream audio tokens
- **Depth Transformer (Depformer)**: Predicts across RVQ codebook depths
- **Streaming**: Causal attention with rolling KV cache
- **Input**: 8 Mimi codebook streams + text tokens
- **Output**: Next token prediction across all streams simultaneously

### Pocket-TTS Architecture (Kyutai, arxiv:2509.06926)

- **Size**: Lightweight, CPU-targeted
- **Design**: Optimized for low-latency text-to-speech
- **Deployment**: No GPU required

## State Space Models (SSM)

### S4 (Structured State Spaces for Sequence Modeling)

- **Core**: Continuous-time linear system, discretized for sequences
- **Complexity**: O(n log n) via FFT, vs O(n²) for attention
- **Strengths**: Very long sequences (>10k tokens), fixed memory
- **Weaknesses**: Weaker at in-context learning than Transformers

### Mamba (Selective State Spaces)

- **Core**: Input-dependent (selective) state transitions
- **Complexity**: O(n) linear in sequence length
- **Inference**: RNN-like (constant memory per step)
- **Key Innovation**: Selection mechanism makes SSM content-aware
- **Mamba-2**: Simplified, closer to linear attention, hardware-efficient

### Hyena

- **Core**: Implicit long convolutions
- **Complexity**: O(n log n)
- **Use**: Drop-in replacement for attention in some settings

## Mixture of Experts (MoE) / Sparse MoE (SMoE)

Modern MoE architectures are almost exclusively **sparse** (SMoE): only top-k experts are activated per token, achieving sublinear compute scaling. Dense MoE (all experts active) serves mainly as a theoretical baseline. Key surveys: arxiv:2507.11181 (MoE for LLMs, 2025), arxiv:2602.08019 (SMoE algorithm + systems, 2026).

> Cross-reference: system stacks (DeepSpeed-MoE, Tutel, X-MoE), expert parallelism, routing theory, and inference patterns in `skills/cutting-edge-architectures/references/moe-sparse-routing.md`.

### Design Parameters

| Parameter | Typical Values | Notes |
| ----------- | --------------- | ------- |
| Num experts | 8, 16, 64 | More experts = more total params |
| Top-k | 1 or 2 | Experts activated per token |
| Expert size | Same as dense FFN | Or smaller (expert parallelism) |
| Load balance loss | 0.01-0.1 weight | Prevent expert collapse |
| Shared expert | 0 or 1 | Always-on expert for common patterns |

### Notable MoE Models

- **Mixtral 8×7B**: 8 experts, top-2, ~12B active params of 46B total
- **Switch Transformer**: Top-1 routing, simplified training
- **DeepSeek-MoE**: Fine-grained experts (256 → 8 activated) + shared experts, auxiliary-loss-free routing via expert isolation loss
- **DeepSeek-V3**: 671B total / 37B activated, FP8 training, MLA + auxiliary-loss-free MoE
- **Grok-1** (xAI): 314B total / ~73B active, 8 experts top-2, largest open-weights MoE at release

## Neural Audio Codecs

### Mimi (Kyutai)

| Parameter | Value |
| ----------- | ------- |
| Frame rate | 12.5 Hz (80ms per frame) |
| Bitrate | 1.1 kbps |
| Codebooks | 8 (Residual VQ) |
| Codebook size | 2048 entries per codebook |
| Backbone | SEANet (encoder-decoder CNN) |
| Sample rate | 24 kHz |

### Other Codecs

- **EnCodec** (Meta): 24 kHz, 1.5-24 kbps, 2-32 codebooks
- **SoundStream** (Google): 24 kHz, 3-18 kbps, multi-scale discriminator
- **DAC** (Descript): 44.1 kHz, improved quality at low bitrates

## Generative Architecture Parameters

### Diffusion Models

| Parameter | Typical Values |
| ----------- | --------------- |
| Timesteps | 1000 (training), 20-50 (inference with DDIM) |
| Noise schedule | Linear, cosine, or learned |
| Guidance | Classifier-free, scale 3-15 |
| U-Net channels | 128-512 |
| Attention resolutions | 8, 16, 32 |

### Flow Matching (LSD, Kyutai)

| Parameter | Description |
| ----------- | ------------- |
| ODE solver | Euler, RK45, adaptive |
| Steps | 10-100 (fewer than diffusion) |
| Conditioning | Text, speaker embedding, style |
| Transport | Optimal transport (OT) paths |

## Scaling Laws

### Chinchilla Scaling (Hoffmann et al., 2022)

```text
ptimal tokens ≈ 20 × model parameters
Compute-optimal training: balance model size and data equally
```

| Model Size | Optimal Tokens | Optimal Compute (FLOPs) |
| ----------- | --------------- | ---------------------- |
| 1B | 20B | ~3.6 × 10¹⁹ |
| 7B | 140B | ~2.5 × 10²⁰ |
| 70B | 1.4T | ~2.5 × 10²¹ |

### Inference Scaling

```text
V cache memory per token ≈ 2 × n_layers × d_model × 2 bytes (fp16)
Generation latency ∝ n_layers × (attention + FFN)
Throughput ∝ batch_size / latency (up to memory limit)
```

---

## JEPA / LeCun Predictive Architectures

> Cross-reference: full training objectives, code patterns, and domain application guide in `skills/cutting-edge-architectures/references/jepa-world-models.md`.

Joint Embedding Predictive Architecture (LeCun, 2022 — arxiv:2301.08243). Predicts representations of missing or future parts in **latent space** rather than pixel/token space — avoids the generative pixel/token reconstruction mode collapse trap.

| Model | Domain | Parameters | Key Feature |
| ------- | -------- | ----------- | ------------- |
| I-JEPA (Meta FAIR, 2023) | Image | ViT-H (632M) | Patch masking prediction in latent space |
| V-JEPA 2 (Meta FAIR, 2025) | Video | ViT-G (1.1B) | 2M+ video clips, action-conditioned planning |
| V-JEPA 2.1 (Meta FAIR, 2025) | Video | ViT-G (1.1B) | Robotics alignment (arxiv:2603.14482) |
| LLM-JEPA (Meta FAIR, 2025) | Language | 1B–7B | MSE prediction in token embedding space |
| VL-JEPA (Meta FAIR, 2025) | Vision-Language | ViT-G + LLM | Multimodal latent prediction |
| Causal-JEPA | Video-Language | Varies | Causal temporal modeling |
| LeJEPA | Embodied | Varies | Hierarchical latent planning |
| LeWorldModel (Meta FAIR, 2025) | Embodied | Varies | Action-conditioned world model |

**DyT (Dynamic Tanh Normalization — arxiv:2503.10622)**: Drop-in replacement for LayerNorm/RMSNorm. Scales element-wise: `DyT(x) = γ · tanh(α · x) + β`. Used in V-JEPA 2 and multiple 2024–2025 SOTA models. Eliminates normalization computation cost while matching or exceeding LayerNorm quality.

---

## DeepSeek Architecture Family

> Cross-reference: MLA implementation code in `skills/cutting-edge-architectures/references/attention-innovations.md`.

| Variant | Key Innovation | Scale |
| --------- | -------------- | ------- |
| DeepSeek-V2 (arxiv:2405.04434) | Multi-head Latent Attention (MLA) + DeepSeekMoE | 236B total / 21B activated |
| DeepSeek-V3 (2024) | MLA + FP8 training + auxiliary-loss-free MoE | 671B total / 37B activated |
| DeepSeek-R1 (2025) | MLA + Group Relative Policy Optimization (GRPO) RL fine-tuning | 671B total / 37B activated |

**DeepSeekMoE** uses fine-grained expert segmentation (256 fine-grained → 8 activated) with expert isolation loss to prevent routing collapse. Combined with MLA, achieves 5.76× inference throughput vs standard MHA+MoE.
