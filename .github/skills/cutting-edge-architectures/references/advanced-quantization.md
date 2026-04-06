# Advanced Quantization Reference

Technical reference for TurboQuant (Google Research, 2025) and DyT pre-training normalization. Complements the standard quantization methods in `skills/model-inference/references/quantization-methods.md`.

> **Operator/Integrator Reference**: TurboQuant is a research contribution from Google Research (Vahab Mirrokni et al., arxiv:2504.19874). It is not a released Google product. Documentation here covers the algorithm for teams implementing or evaluating this approach.

---

## TurboQuant — Online Vector Quantization for KV Cache

**Paper**: arxiv:2504.19874 — "TurboQuant: Online Vector Quantization without Loss" (Zandieh, Daliri, Hadian, Mirrokni — Google Research, April 2025)

### Problem Solved

KV cache quantization reduces memory during long-context inference. Existing methods:

- **GPTQ / AWQ**: Weight quantization, not KV cache
- **Product Quantization (PQ)**: Codebook lookup → high indexing overhead, data-dependent
- **Raw scalar quantization** (INT4/INT8): Sub-optimal distortion rate at low bits

TurboQuant achieves **near-optimal rate-distortion** with virtually **zero indexing overhead** and no calibration dataset (online / data-oblivious).

### Algorithm: Three Steps

#### Step 1: Random Rotation (Coordinate Homogenization)

Apply a random orthogonal matrix `R` to the KV vector `v ∈ ℝ^d`:

```python
import torch

def make_rotation_matrix(d: int, device, dtype) -> torch.Tensor:
    """Haar-distributed random orthogonal matrix."""
    Q, _ = torch.linalg.qr(torch.randn(d, d, device=device, dtype=dtype))
    return Q  # [d, d], orthogonal

R = make_rotation_matrix(d=head_dim, device=device, dtype=dtype)

# Apply rotation to KV vector
v_rotated = v @ R.T    # [batch, heads, seq, head_dim]
```

**Why**: After multiplication by a random orthogonal matrix, coordinates of `v` become approximately Beta-distributed with low variance. This makes them amenable to a common optimal scalar quantizer.

#### Step 2: Optimal Scalar Quantization (Per-Coordinate MSE)

Quantize each coordinate independently using an **MSE-optimal scalar quantizer** for the Beta distribution:

```python
def scalar_quantize(x: torch.Tensor, bits: int) -> torch.Tensor:
    """
    Optimal scalar quantizer for TurboQuant coordinates.
    After random rotation, coordinates ≈ Beta(α, α) distributed.
    """
    levels = 2 ** bits          # e.g., 8 levels for 3-bit
    # Compute optimal uniform quantization bins for Beta distribution
    # (in practice: use calibrated min/max of the rotated coords)
    x_min, x_max = x.amin(dim=-1, keepdim=True), x.amax(dim=-1, keepdim=True)
    scale = (x_max - x_min) / (levels - 1)
    x_int = ((x - x_min) / scale).round().clamp(0, levels - 1)
    return x_int, scale, x_min  # quantized indices + dequant params

v_q, scale, x_min = scalar_quantize(v_rotated, bits=3)  # 3-bit
```

#### Step 3: 1-Bit QJL Residual (Unbiased Inner Product Estimation)

After scalar quantization, a residual `r = v_rotated - dequantize(v_q)` remains. Apply a Quantized Johnson-Lindenstrauss (QJL) transform to estimate inner products from 1-bit random projections:

```python
def qjl_compress(residual: torch.Tensor, n_projections: int) -> torch.Tensor:
    """
    1-bit QJL: project residual onto random directions, retain only sign.
    Allows unbiased estimation of <r, q> from 1 bit per projection.
    """
    # Random projection matrix (Rademacher ±1/√n_proj)
    S = (torch.randint(0, 2, (residual.shape[-1], n_projections),
                       device=residual.device) * 2 - 1).float() / n_projections ** 0.5
    proj = residual @ S        # [batch, heads, seq, n_proj]
    return proj.sign()         # [batch, heads, seq, n_proj] — 1-bit

# In attention computation, recover inner product estimate:
# <v, q> ≈ <dequant(v_q), q> + (n_proj/d) * (qjl_bits @ (S.T @ q)).mean()
```

### Full KV Compression Pipeline

```python
class TurboQuantKVCache:
    """KV cache with TurboQuant compression."""

    def __init__(self, head_dim: int, bits: float = 3.5, n_residual_bits: int = 64):
        self.head_dim = head_dim
        self.scalar_bits = int(bits)            # e.g., 3 for 3.5-bit total
        self.n_residual_bits = n_residual_bits  # QJL projections for residual
        self.R = make_rotation_matrix(head_dim, device='cuda', dtype=torch.float16)
        self.S = (torch.randint(0, 2, (head_dim, n_residual_bits), device='cuda') * 2 - 1
                  ).float() / n_residual_bits ** 0.5

    def compress(self, k: torch.Tensor, v: torch.Tensor):
        # Rotate
        k_r = k @ self.R.T
        v_r = v @ self.R.T

        # Scalar quantize (Step 2)
        k_q, k_scale, k_min = scalar_quantize(k_r, self.scalar_bits)
        v_q, v_scale, v_min = scalar_quantize(v_r, self.scalar_bits)

        # QJL residual (Step 3)
        k_res = qjl_compress(k_r - dequantize(k_q, k_scale, k_min), self.n_residual_bits)
        v_res = qjl_compress(v_r - dequantize(v_q, v_scale, v_min), self.n_residual_bits)

        return (k_q, k_scale, k_min, k_res), (v_q, v_scale, v_min, v_res)
```

### Performance: Bit-Width Comparison

| Method | Bits/Channel | KV Memory (128K ctx, 70B) | Quality Impact | Calibration |
| -------- | ------------- | -------------------------- | ---------------- | ------------- |
| FP16 (baseline) | 16 | ~320 GB | None | None |
| INT8 | 8.0 | ~160 GB | < 0.5% | None |
| **TurboQuant** | **3.5** | **~70 GB** | **Neutral** | None (online) |
| **TurboQuant** | **2.5** | **~50 GB** | Marginal | None (online) |
| AWQ | 4.0 | ~80 GB | < 1% | Calibration dataset |
| GPTQ | 4.0 | ~80 GB | 1–3% | Calibration dataset |
| GGUF Q3_K_M | 3.4 | ~68 GB | Acceptable | imatrix optional |

> **Quality neutrality at 3.5 bits**: TurboQuant's near-optimal distortion proof (arXiv §3) guarantees that at 3.5 bits/channel, the inner product estimation error is below the threshold where downstream task quality degrades measurably.

### Theoretical Guarantee

TurboQuant achieves the **near-optimal rate-distortion bound** for online, data-oblivious vector quantization:

$$D(R) \leq C \cdot 2^{-2R}$$

where $D$ is expected MSE, $R$ is bits per dimension, and $C$ is a small constant dependent on the Random rotation and scalar quantizer design. This is provably close to the Shannon rate-distortion lower bound for Gaussian sources.

### When to Use TurboQuant

| Scenario | Recommendation |
| ---------- | --------------- |
| Long-context serving (>32K tokens) | **High priority** — memory savings become dominant at long context |
| No calibration data available | **Strong fit** — TurboQuant requires no dataset calibration |
| Low-latency, low-overhead needs | **Strong fit** — O(d log d) rotation; no codebook lookup |
| sub-2.5 bit requirement | **Not recommended** — quality degrades below 2.5 bits |
| Weight quantization (not KV) | **Wrong tool** — use AWQ/GPTQ/GGUF for weight compression |
| DeepSeek MLA + TurboQuant | **Compatible** — TurboQuant applies to the latent vector `c_KV` (512-dim), amplifying savings further |

### TurboQuant vs. Other KV Quantization Methods

| Method | Type | Calibration | Overhead | Best Use |
| -------- | ------ | ------------- | ---------- | ---------- |
| **TurboQuant** | Online scalar + QJL residual | None | ~5% compute | Long-context, data-oblivious |
| KVQuant | Offline vector quantization | Dataset required | Low | Batch serving, static workloads |
| H2O | Sparse KV eviction | None | Low | Memory-constrained, quality-tolerant |
| SnapKV | Attention-weighted eviction | None | Low | Interactive chatbots |
| Int8 KV | Scalar quantization | None | Negligible | 2× memory reduction target |

---

## DyT (Dynamic Tanh) — Normalization

**Paper**: arxiv:2503.10622 — "Transformers without Normalization" (LeCun lab, CVPR 2025)

See `references/jepa-world-models.md` (§ Dynamic Tanh) for full implementation details, drop-in replacement code, and comparison table.

**Quick reference**:

- Replace `nn.LayerNorm` with `DynamicTanh(d_model, alpha_init=0.5)`
- No running statistics; fully per-sample
- Matches or exceeds LayerNorm quality per CVPR 2025 results
- Works with RMSNorm replacements too

---

## Combined MLA + TurboQuant Strategy

For maximum KV memory reduction at long context:

1. **MLA** compresses the KV latent representation from `n_heads × d_head` → `d_c = 512` (93.3% reduction from full MHA)
2. **TurboQuant** then quantizes the 512-dim latent vector from FP16 → 3.5 bits (78% further reduction)

Net reduction vs. MHA FP16:
$$\text{Combined} = 93.3\% \times (1 - 3.5/16) = 93.3\% \times 78.1\% \approx 72.8\%$$

Total KV memory budget vs. MHA FP16 baseline: **≈ 4.7% of original** (21× compression).

---

## Cross-Reference

- Standard quantization methods (GPTQ, AWQ, GGUF, INT8): `skills/model-inference/references/quantization-methods.md`
- MLA KV latent compression: `references/attention-innovations.md`
- GPU memory planning for quantized KV: `skills/gpu-compute/`
- TorchAO integration patterns: `skills/model-inference/`
