# Quantization Methods Reference

Detailed comparison of model quantization techniques for inference optimization.

## Method Comparison

| Method | Weight Bits | Activation Bits | Calibration | GPU Required | Quality Impact |
| -------- | ------------ | ---------------- | ------------- | ------------- | --------------- |
| FP16/BF16 | 16 | 16 | None | Yes | Negligible |
| torchao INT8 | 8 | 8 | Activation stats | Yes | < 1% |
| SmoothQuant | 8 | 8 | Smoothing factor | Yes | < 1% |
| GPTQ | 4 (or 3) | 16 | Calibration dataset | Yes | 1-3% |
| AWQ | 4 | 16 | Activation-aware | Yes | < 1% |
| bitsandbytes NF4 | 4 | 16 | None | Yes | 1-2% |
| GGUF | 2-8 mixed | 16 | imatrix (optional) | No (CPU) | Varies |

## torchao INT8 (Reference: Kyutai/Moshi Pattern)

Used in Moshi (`scripts/export_quantized.py`):

```python
import torchao

# Dynamic quantization (weights static, activations dynamic)
torchao.quantize_(model, torchao.quantization.int8_dynamic_activation_int8_weight())

# Or weight-only quantization
torchao.quantize_(model, torchao.quantization.int8_weight_only())
```

**Pros**: Simple, PyTorch-native, good quality
**Cons**: GPU-only (Ampere+), limited to INT8

## GPTQ (Post-Training Quantization)

Layer-by-layer quantization using second-order information:

```python
from auto_gptq import AutoGPTQForCausalLM

# Quantize with calibration data
model = AutoGPTQForCausalLM.from_pretrained(model_path)
model.quantize(calibration_dataset, batch_size=8)
model.save_quantized(output_path)
```

**Calibration**: 128-512 samples from training distribution
**Group size**: 128 (default), smaller = better quality, slower

## AWQ (Activation-Aware Weight Quantization)

Protects salient weights based on activation magnitudes:

```python
from awq import AutoAWQForCausalLM

model = AutoAWQForCausalLM.from_pretrained(model_path)
model.quantize(tokenizer, quant_config={"w_bit": 4, "q_group_size": 128})
model.save_quantized(output_path)
```

**Advantage**: Better quality than GPTQ at same bit-width
**Speed**: Faster quantization process than GPTQ

## GGUF (llama.cpp Format)

Flexible quantization for CPU and GPU inference:

| Quant Type | Bits | Size (7B) | Quality | Speed |
| ----------- | ------ | ----------- | --------- | ------- |
| Q2_K | 2.6 | 2.7 GB | Poor | Fastest |
| Q3_K_M | 3.4 | 3.3 GB | Acceptable | Fast |
| Q4_K_M | 4.8 | 4.1 GB | Good | Good |
| Q5_K_M | 5.7 | 4.8 GB | Very good | Moderate |
| Q6_K | 6.6 | 5.5 GB | Excellent | Slower |
| Q8_0 | 8.0 | 7.2 GB | Near-lossless | Slowest |

**imatrix calibration**: Improves quality for low-bit (Q2-Q3) by weighting important weights

## bitsandbytes (QLoRA)

4-bit NormalFloat for fine-tuning:

```python
from transformers import BitsAndBytesConfig

bnb_config = BitsAndBytesConfig(
    load_in_4bit=True,
    bnb_4bit_quant_type="nf4",
    bnb_4bit_compute_dtype=torch.bfloat16,
    bnb_4bit_use_double_quant=True,  # quantize the quantization constants
)
```

**Use case**: QLoRA fine-tuning (4-bit base + LoRA adapters)
**Memory**: ~4.5 GB for 7B model (vs 14 GB FP16)

## Quality Evaluation

### How to Measure Quantization Impact

1. **Perplexity** on held-out text (WikiText-2, C4)
2. **Task-specific metrics**: WER for speech, BLEU for translation
3. **Human evaluation**: MOS for audio quality
4. **Needle-in-haystack**: Long-context retrieval accuracy

### Acceptable Quality Loss

| Use Case | Max Acceptable Degradation |
| ---------- | --------------------------- |
| Production (quality-critical) | < 0.5% on primary metric |
| Production (cost-sensitive) | < 2% |
| Edge/mobile | < 5% |
| Development/testing | Any (speed matters) |

## TurboQuant (Google Research — Online KV Cache Quantization)

> Cross-reference: full 3-step algorithm, Python implementation code, and combined MLA+TurboQuant strategy in `skills/cutting-edge-architectures/references/advanced-quantization.md`.

Google Research (arxiv:2504.19874). Online vector quantization of **KV cache** (not weights) with near-optimal rate-distortion guarantees.

**Target**: Long-context inference memory bottleneck. Not a weight quantization method.

**Algorithm (3 steps)**:

1. **Random Rotation**: Apply orthogonal matrix to KV vectors — isotropizes quantization error
2. **Optimal Scalar Quantizer**: Per-head scalar quantization with optimal step size selection
3. **1-bit QJL Residual**: Johnson-Lindenstrauss residual encoding for remaining error

| Method | Effective Bits | Quality Loss | Type |
| -------- | -------------- | ------------- | ------ |
| FP16 baseline | 16-bit | 0% | Uncompressed |
| TurboQuant | 3.5-bit | Quality-neutral (proven optimal) | KV cache online |
| GPTQ 4-bit | 4-bit | ≤1% on perplexity | Weight post-training |
| AWQ 4-bit | 4-bit | ≤1% on perplexity | Weight post-training |
| KVQuant | 4-bit | ≤2% on perplexity | KV cache post-training |

**When to use**: Context lengths ≥ 32K where KV cache exceeds GPU VRAM; online (no calibration data needed); NVIDIA Ampere+ (H100 optimal). Not for: edge/CPU, weight compression, models < 7B.

**Combined with MLA**: MLA (93.3% KV reduction) + TurboQuant (3.5-bit) → ~21× total KV compression vs FP16 MHA.

---

## Decision Guide

```text
arget hardware?
├── CPU only → GGUF (Q4_K_M or Q5_K_M)
├── Apple Silicon → MLX (native quantization) or GGUF
├── NVIDIA GPU (Ampere+) →
│   ├── Want simplest? → torchao INT8
│   ├── Want smallest weight quant? → AWQ 4-bit
│   ├── Want KV cache compression? → TurboQuant (3.5-bit, context ≥32K)
│   └── Want fine-tuning? → bitsandbytes NF4 (QLoRA)
└── NVIDIA GPU (older) → FP16 or GPTQ

Memory budget?
├── < 4 GB → Q3_K or Q4_K (GGUF)
├── 4-8 GB → AWQ/GPTQ 4-bit or Q5_K/Q6_K
├── 8-16 GB → INT8 (torchao) or FP16 (small models)
└── > 16 GB → FP16/BF16 (or FP16 + TurboQuant KV if long context)

Long-context (≥32K) KV cache bottleneck?
└── Yes → TurboQuant (quality-neutral at 3.5 bits) or MLA architecture
```
