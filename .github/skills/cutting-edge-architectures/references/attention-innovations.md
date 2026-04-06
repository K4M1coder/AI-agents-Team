# Attention Innovations Reference

Detailed technical reference for DeepSeek MLA and Kimi AttnRes — two major 2024–2026 advances in attention mechanism design.

> **Operator/Integrator Reference**: These techniques are open-source research contributions. MLA originates from DeepSeek-AI (arxiv:2405.04434). AttnRes originates from the Kimi/Moonshot AI team (arxiv:2603.15031). Full implementation patterns are documented here for use in projects that adopt these architectures.

---

## DeepSeek MLA (Multi-head Latent Attention)

**Paper**: arxiv:2405.04434 — DeepSeek-V2: A Strong, Economical, and Efficient Mixture-of-Experts Language Model (May 2024)
**Used in**: DeepSeek-V2, DeepSeek-V3, DeepSeek-R1 (all production models as of 2025)

### Problem Solved

Standard MHA KV cache grows linearly with sequence length and number of heads:

```text
KV cache size = n_heads × d_head × seq_len × 2 × dtype_bytes
# For a 64-head, d_head=128, fp16 model at 128K context:
# 64 × 128 × 131072 × 2 × 2 bytes = 4 GB per layer
```

MLA replaces this with a compressed latent vector, reducing cache by **93.3%**.

### Core Algorithm

#### Standard MHA (baseline)

```text
K = W_k(x)   # shape: [seq, n_heads * d_head]
V = W_v(x)   # shape: [seq, n_heads * d_head]
# Cache K and V per token at each layer
```

#### MLA Compression

```text
# DOWN-projection: compress to latent vector c_KV
c_KV = W_DKV(x)    # shape: [seq, d_c] where d_c = 512 << n_heads * d_head (16384)

# UP-projection: recover K and V from latent
K = W_UK(c_KV)     # [seq, n_heads * d_head]
V = W_UV(c_KV)     # [seq, n_heads * d_head]

# Cache ONLY c_KV (512 dims vs 16384 dims = 32× compression)
```

#### Decoupled RoPE (position encoding)

Standard RoPE cannot be applied inside the compressed space. MLA uses a separate decoupled key:

```text
# Compute decoupled RoPE key (not compressed; cached separately)
k_rope = W_KR(x_rope)             # small dedicated projection
k_rope = apply_rope(k_rope, pos)  # RoPE applied here

# Final key = concat(W_UK(c_KV), k_rope)  [per head]
K_full = concat(W_UK(c_KV), k_rope, dim=-1)
```

The query has a corresponding decoupled component:

```text
q_rope = W_QR(x)
q_rope = apply_rope(q_rope, pos)
Q_full = concat(W_UQ(c_KQ), q_rope, dim=-1)
```

### Configuration (DeepSeek-V2 128K)

| Parameter | Value | Notes |
| ----------- | ------- | ------- |
| `d_model` | 5120 | Hidden dim |
| `n_heads` | 128 | Query heads |
| `d_head` | 128 | Per-head dimension |
| `d_c` (KV latent dim) | 512 | Compressed KV dim — **the cached vector** |
| `d_c_rope` | 64 | Decoupled RoPE key/query dim |
| KV cache reduction | 93.3% | vs MHA baseline |
| Throughput improvement | 5.76× | End-to-end generation throughput |

### Loading from HF Hub (Integration Pattern)

```python
from transformers import AutoModelForCausalLM, AutoTokenizer

# DeepSeek-V3 uses MLA natively — no additional config needed
model = AutoModelForCausalLM.from_pretrained(
    "deepseek-ai/DeepSeek-V3",
    torch_dtype=torch.bfloat16,
    device_map="auto",
    trust_remote_code=True,   # required for MLA implementation
)
tokenizer = AutoTokenizer.from_pretrained("deepseek-ai/DeepSeek-V3")
```

> **Note**: The `trust_remote_code=True` flag is required because MLA uses a custom attention implementation in the model's `modeling_deepseek.py`. Review this file before enabling in production environments.

### Implementing MLA from Scratch (Key Components)

```python
import torch
import torch.nn as nn

class MultiHeadLatentAttention(nn.Module):
    def __init__(self, d_model, n_heads, d_c, d_c_rope):
        super().__init__()
        self.n_heads = n_heads
        self.d_head = d_model // n_heads
        self.d_c = d_c

        # KV compression (down-project)
        self.W_DKV = nn.Linear(d_model, d_c, bias=False)

        # KV up-projections (recover K and V from latent)
        self.W_UK = nn.Linear(d_c, n_heads * self.d_head, bias=False)
        self.W_UV = nn.Linear(d_c, n_heads * self.d_head, bias=False)

        # Query compression
        self.W_DQ = nn.Linear(d_model, d_c, bias=False)
        self.W_UQ = nn.Linear(d_c, n_heads * self.d_head, bias=False)

        # Decoupled RoPE projections
        self.W_QR = nn.Linear(d_model, n_heads * d_c_rope, bias=False)
        self.W_KR = nn.Linear(d_model, d_c_rope, bias=False)

        self.W_o = nn.Linear(n_heads * self.d_head, d_model, bias=False)

    def forward(self, x, kv_cache=None):
        B, S, _ = x.shape

        # Down-project to KV latent (THIS is what gets cached)
        c_KV = self.W_DKV(x)   # [B, S, d_c]

        # Store c_KV in cache (not full K, V)
        if kv_cache is not None:
            kv_cache.append(c_KV)

        # Up-project to recover K and V
        K = self.W_UK(c_KV)    # [B, S, n_heads * d_head]
        V = self.W_UV(c_KV)    # [B, S, n_heads * d_head]

        # Query path
        c_Q = self.W_DQ(x)
        Q = self.W_UQ(c_Q)     # [B, S, n_heads * d_head]

        # (Decoupled RoPE handling omitted for brevity — see paper §2.1.2)

        # Standard attention computation
        Q = Q.view(B, S, self.n_heads, self.d_head).transpose(1, 2)
        K = K.view(B, S, self.n_heads, self.d_head).transpose(1, 2)
        V = V.view(B, S, self.n_heads, self.d_head).transpose(1, 2)
        attn = torch.nn.functional.scaled_dot_product_attention(Q, K, V)
        attn = attn.transpose(1, 2).contiguous().view(B, S, -1)
        return self.W_o(attn)
```

### When to Use MLA

| Scenario | Recommendation |
| ---------- | --------------- |
| Serving long-context models (>32K tokens) | **High priority** — KV memory savings are substantial |
| Training new large decoder models | **Consider** — adoption cost justified at >30B params |
| Replacing an existing MHA model mid-training | **Do not** — requires architectural change; do at pre-training |
| CPU inference | **Low priority** — TurboQuant is simpler and works on any attention type |
| Fine-tuning a DeepSeek model | **Automatic** — MLA is already present; no change needed |

---

## Kimi Attention Residuals (AttnRes)

**Paper**: arxiv:2603.15031 — "Attention Residuals" (Kimi Team / Moonshot AI, March 2026)
**Used in**: Kimi Linear architecture (48B total parameters / 3B activated), pre-trained on 1.4T tokens

### Problem Solved by attention residuals

In PreNorm Transformer architectures, the residual path carries an increasingly dominant signal as depth increases:

```text
# Standard Transformer layer (PreNorm)
x = x + f(LayerNorm(x))    # residual has fixed unit weight
```

The fixed unit-weight residual causes **PreNorm dilution**: `x` dominates over `f(x)` at depth, gradients become imbalanced, layer outputs have non-uniform magnitudes.

### Core Idea: Replace Fixed Residual with Depth-Wise Attention

AttnRes computes an **input-dependent** weighted combination of *all preceding layer outputs*:

```text
# Standard residual (fixed)
h_L = h_{L-1} + f(h_{L-1})

# AttnRes (learned depth-wise weights)
w = softmax([q_L · k_0, q_L · k_1, ..., q_L · k_{L-1}])  # attention over layer stack
h_L = sum_i(w_i × h_i) + f(h_{L-1})
```

Where `q_L` is a per-layer query derived from `h_{L-1}` and `k_i` are per-layer keys derived from each `h_i`.

### Block AttnRes (Production Variant)

Full AttnRes is memory-intensive at large depth (must store all previous layer outputs). Block AttnRes partitions layers into blocks of size `B`:

```text
# Partition layers into blocks [0..B-1], [B..2B-1], ...
# Within each block: full AttnRes over block of B layers
# Across blocks: single representative vector per block

block_representatives = [mean(h_{b*B : (b+1)*B}) for b in range(num_blocks)]
w_block = softmax([q_L · k_b for b in range(current_block)])   # cross-block weights
w_local = softmax([q_L · k_i for i in current_block_range])    # within-block weights
h_L = alpha * sum_block(w_block * block_rep) + (1-alpha) * sum_local(w_local * h_i) + f(h_{L-1})
```

### Two-Phase Computation for Training Efficiency

AttnRes requires H matrices stored simultaneously (all layer outputs). Two-phase strategy:

1. **Forward pass phase 1**: Compute all hidden states, store compact representatives (block means)
2. **Forward pass phase 2**: Recompute AttnRes weights using stored representatives; back-prop through attention weights only

This reduces peak memory from O(L × d) to O(B × d + additional attention weights).

### Effect on Model Behavior

| Metric | PreNorm Baseline | AttnRes |
| -------- | ----------------- | --------- |
| Layer output magnitude variance | High (dilution at depth) | Low (uniform across depth) |
| Gradient flow | Dominated by residual path | Balanced through learned weights |
| Downstream task performance | Baseline | +2–5% absolute on selected benchmarks |
| Training convergence | Standard | Equal or faster |
| Inference overhead | — | +5–10% compute (attention over layer stack) |

### Configuration: Kimi Linear (arxiv:2603.15031)

| Parameter | Value |
| ----------- | ------- |
| Total parameters | 48B |
| Activated parameters | 3B (sparse MoE) |
| Pre-training tokens | 1.4T |
| Block size (Block AttnRes) | 4 layers |
| AttnRes query/key dim | 128 |

### When to Use AttnRes

| Scenario | Recommendation |
| ---------- | --------------- |
| Training a deep Transformer (>48 layers) | **Consider** — PreNorm dilution is most pronounced here |
| Models with PreNorm + heavy residual dominance | **High priority** — directly addresses dilution |
| Shallow models (<24 layers) | **Low priority** — diminishing returns; fixed residual adequate |
| Already using post-norm | **Skip** — post-norm does not suffer from dilution |
| Block AttnRes as drop-in | **Feasible** — replace `x + f(LN(x))` with `Block_AttnRes(x) + f(LN(x))` |

---

## Cross-Reference

- Full KV quantization techniques (TurboQuant, AWQ, GPTQ): `references/advanced-quantization.md`
- Standard attention variants (MHA, GQA, Flash Attention): `skills/model-architectures/references/attention-mechanisms.md`
- MLA inference serving patterns: `skills/model-inference/references/serving-frameworks.md`
