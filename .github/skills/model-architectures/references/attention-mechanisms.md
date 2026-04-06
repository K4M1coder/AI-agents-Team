# Attention Mechanisms Reference

Detailed comparison of attention variants used in modern architectures.

## Multi-Head Attention (MHA)

The standard attention mechanism (Vaswani et al., 2017).

```text
, K, V = W_q(x), W_k(x), W_v(x)        # Project to h heads
Attention(Q, K, V) = softmax(QK^T / √d_k) V
Output = Concat(head_1, ..., head_h) W_o
```

| Aspect | Details |
| -------- | --------- |
| Complexity | O(n² × d) per layer |
| KV cache size | n_heads × d_head × seq_len × 2 (K + V) |
| Parameters | 4 × d_model² per layer (Q, K, V, O projections) |
| Strengths | Most expressive, well-understood |
| Weaknesses | Quadratic in sequence length, large KV cache |

## Multi-Query Attention (MQA)

Single KV head shared across all query heads (Shazeer, 2019).

| Aspect | Details |
| -------- | --------- |
| KV cache size | 1 × d_head × seq_len × 2 (h× reduction) |
| Quality impact | Slight degradation vs MHA |
| Speed improvement | 2-4× faster inference (less KV memory) |
| Used in | PaLM, Falcon, StarCoder |

## Grouped Query Attention (GQA)

KV heads shared in groups (Ainslie et al., 2023). Interpolates between MHA and MQA.

| Aspect | Details |
| -------- | --------- |
| Groups | Typically n_heads / 4 or n_heads / 8 |
| KV cache size | n_groups × d_head × seq_len × 2 |
| Quality | Close to MHA, much better than MQA |
| Speed | Proportional to group count |
| Used in | Llama 2/3, Mistral, Moshi |

### Moshi GQA Configuration

```text
_heads = 32, n_kv_heads = 8 (4 groups of 8)
d_model = 4096, d_head = 128
KV cache: 8 × 128 × seq_len × 2 bytes (fp16)
```

## Flash Attention (Tri Dao et al., 2022/2023)

IO-aware exact attention algorithm. Same math, different computation order.

| Aspect | Details |
| -------- | --------- |
| Complexity | O(n²) compute, O(n) memory |
| Key idea | Tiling + online softmax, never materialize full attention matrix |
| Versions | FlashAttention-1 (2022), FlashAttention-2 (2023), FlashAttention-3 (Hopper) |
| Hardware | CUDA / Metal (via MLX), Triton kernels |
| Speedup | 2-4× vs standard attention, 5-20× memory reduction |
| Caveats | Custom CUDA kernels, limited to specific dtypes (bf16/fp16) |

## Sliding Window Attention

Local attention within a fixed window (Beltagy et al., 2020).

| Aspect | Details |
| -------- | --------- |
| Window size | 4096-32768 tokens typically |
| Complexity | O(n × w) where w = window size |
| KV cache | Only window_size tokens retained |
| Strengths | Handles very long sequences, bounded memory |
| Weaknesses | Cannot attend to distant tokens directly |
| Used in | Mistral (window=4096), Longformer |

## Linear Attention

Replace softmax with kernel function for O(n) complexity.

| Variant | Key Idea | Quality |
| --------- | ---------- | --------- |
| **Performer** | Random feature approximation | ~95% of softmax |
| **cosFormer** | Cosine re-weighting | Better than Performer |
| **RWKV** | Linear attention + decay | Competitive with Transformer |

## Cross-Attention

Used in encoder-decoder models and multi-modal fusion.

```text
 = W_q(decoder_state)
K, V = W_k(encoder_output), W_v(encoder_output)
Attention(Q, K, V) = softmax(QK^T / √d_k) V
```

| Use Case | Example |
| ---------- | --------- |
| Seq2seq | T5, BART |
| Multi-modal | Flamingo (text queries, image keys/values) |
| Speech-text | Whisper decoder attends to encoder |
| Conditioning | Diffusion models conditioned on text |

## Rotary Position Embedding (RoPE)

Relative position encoding via rotation in complex space (Su et al., 2021).

```text
oPE(x, pos) = x × cos(pos × θ) + rotate(x) × sin(pos × θ)
θ_i = base^(-2i/d), base = 10000 (default)
```

| Aspect | Details |
| -------- | --------- |
| Type | Relative position (no absolute) |
| Extrapolation | Good with NTK-aware scaling or YaRN |
| Strengths | No max position limit, relative distance preserved |
| Used in | Llama, Mistral, Moshi, CodeLlama |
| Extension methods | NTK-aware, YaRN, Linear scaling, Dynamic scaling |

## DeepSeek Multi-head Latent Attention (MLA)

> Cross-reference: full implementation code and algorithm in `skills/cutting-edge-architectures/references/attention-innovations.md`.

DeepSeek-AI (arxiv:2405.04434, "DeepSeek-V2"). Low-rank joint compression of KV cache.

| Aspect | Details |
| -------- | --------- |
| KV cache reduction | 93.3% vs MHA (d_c=512 latent vs 16384 full KV) |
| Throughput gain | 5.76× vs GQA at equivalent batch size |
| Decoupled RoPE | Separate RoPE key projected from full d_h dimension |
| Quality | Matches or exceeds MHA at scale (DeepSeek-V2/V3/R1) |
| Used in | DeepSeek-V2, DeepSeek-V3, DeepSeek-R1 |

**Key formula:**

```text
_KV = W_DKV × h_t           # joint KV down-projection (d_c = 512)
k_C  = W_UK × c_KV           # K up-projection
v_C  = W_UV × c_KV           # V up-projection
Store only c_KV at inference (93.3% smaller KV footprint)
```

**When to use**: Long-context inference (≥32K tokens); KV cache is the memory bottleneck; willing to use `trust_remote_code` HF checkpoint or implement custom layer.

---

## Kimi Attention Residuals (AttnRes)

> Cross-reference: full implementation details in `skills/cutting-edge-architectures/references/attention-innovations.md`.

Moonshot AI (arxiv:2603.15031, "Kimi K2" technical report). Softmax attention over all preceding layer outputs.

| Aspect | Details |
| -------- | --------- |
| Key insight | PreNorm dilutes residual stream; direct attention residuals restore it |
| Global AttnRes | Single attention pool over all L preceding layer outputs |
| Block AttnRes | Partition layers into blocks of 4; pool within each block |
| Scale | Kimi K2: 1T total / 32B activated parameters, 1.4T tokens |
| Complexity | +O(L × d_model) intermediate states stored per layer |

**When to use**: Deep networks (≥60 layers) showing PreNorm dilution; extra memory budget available; post-training phase (two-phase training: phase 1 without AttnRes, phase 2 with AttnRes).

---

## Attention Selection Guide

```text
eed exact attention?
├── Yes → Flash Attention (always use when available)
└── No →
    Sequence length < 8k?
    ├── Yes → GQA (best quality/efficiency balance)
    └── No →
        Sequence length < 128k?
        ├── Yes → Sliding Window + GQA
        └── No → Mamba/SSM or Ring Attention

Inference-heavy workload?
├── Yes → MQA or GQA (smallest KV cache)
│        OR MLA if KV cache is the primary bottleneck
└── No → MHA or GQA (maximum quality)

Memory-constrained?
├── Yes → Flash Attention + GQA + KV cache quantization
│        OR Flash Attention + MLA (93.3% KV reduction)
└── No → Flash Attention + MHA

Deep model (>60 layers) with residual stream quality concerns?
└── Yes → Consider Block AttnRes (Kimi K2 pattern)
```
