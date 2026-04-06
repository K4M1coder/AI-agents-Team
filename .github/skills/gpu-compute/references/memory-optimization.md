# GPU Memory Optimization Reference

Techniques for reducing GPU memory usage during training and inference.

## Memory Analysis

### Where Memory Goes (Training)

```schema
┌─────────────────────────────────────┐
│ GPU Memory                          │
├─────────────────────────────────────┤
│ Model Parameters        ~15-25%    │
│ Gradients               ~15-25%    │
│ Optimizer States         ~30-50%    │  ← Largest component (AdamW)
│ Activations             ~10-30%    │  ← Depends on batch/seq length
│ Temporary Buffers        ~5-10%    │
│ PyTorch Overhead         ~2-5%     │
└─────────────────────────────────────┘
```

### Memory Estimation Formulas

```python
# Parameter memory
param_bytes = num_params * bytes_per_param  # 2 for bf16, 4 for fp32

# Optimizer memory (AdamW)
optimizer_bytes = num_params * 12  # fp32 copy (4) + momentum (4) + variance (4)

# Gradient memory
gradient_bytes = num_params * bytes_per_param

# KV cache (inference)
kv_cache_bytes = 2 * num_layers * (2 * d_model) * seq_len * batch_size * bytes_per_param

# Activation memory (approximate, per layer)
activation_bytes = batch_size * seq_len * d_model * bytes_per_param * ~10-15
```

## Optimization Techniques

### 1. Mixed Precision (bf16)

**Effect**: ~50% memory reduction for parameters, gradients, activations

```python
# PyTorch native AMP
with torch.autocast(device_type="cuda", dtype=torch.bfloat16):
    output = model(input)
    loss = criterion(output, target)
loss.backward()
```

**BF16 vs FP16**:

- BF16: Same exponent range as FP32, no loss scaling needed (Ampere+)
- FP16: Needs loss scaling (GradScaler), can overflow

### 2. Gradient Checkpointing

**Effect**: ~60-70% activation memory reduction, ~30% slower training

```python
from torch.utils.checkpoint import checkpoint

class TransformerBlock(nn.Module):
    def forward(self, x):
        # Recompute activations during backward instead of storing
        return checkpoint(self._forward, x, use_reentrant=False)
```

**When to use**: Large models, long sequences, limited VRAM

### 3. Gradient Accumulation

**Effect**: Simulates larger batch without more memory

```python
for i, batch in enumerate(dataloader):
    loss = model(batch).loss / accum_steps
    loss.backward()
    if (i + 1) % accum_steps == 0:
        optimizer.step()
        optimizer.zero_grad()
```

### 4. FSDP (Fully Sharded Data Parallel)

**Effect**: ~N× memory reduction (N = number of GPUs)

Shards parameters, gradients, and optimizer states across GPUs.
See `model-training/references/distributed-training.md` for details.

### 5. Memory-Efficient Attention

**Flash Attention**: O(n) memory instead of O(n²)

```python
# PyTorch 2.0+ (automatic)
# Enable scaled_dot_product_attention (SDPA)
with torch.nn.attention.sdpa_kernel(torch.nn.attention.SDPBackend.FLASH_ATTENTION):
    output = F.scaled_dot_product_attention(q, k, v)
```

### 6. CPU Offloading

**Effect**: Trade speed for memory by offloading to CPU RAM

```python
# DeepSpeed ZeRO-Offload
{
    "zero_optimization": {
        "stage": 3,
        "offload_optimizer": {"device": "cpu"},
        "offload_param": {"device": "cpu"}
    }
}
```

**Trade-off**: 2-5× slower but can train much larger models

### 7. Quantization (Training)

**QLoRA**: 4-bit base model + 16-bit LoRA adapters

```python
from transformers import BitsAndBytesConfig

bnb_config = BitsAndBytesConfig(
    load_in_4bit=True,
    bnb_4bit_quant_type="nf4",
    bnb_4bit_compute_dtype=torch.bfloat16,
)
```

**Effect**: ~75% memory reduction for frozen params

### 8. KV Cache Optimization (Inference)

| Technique | Memory Savings | Quality Impact |
| ----------- | --------------- | --------------- |
| GQA/MQA | 4-8× less KV cache | Trained into model |
| KV cache quantization | 2-4× | Slight degradation |
| Paged attention (vLLM) | ~0% waste | None |
| Sliding window | Bounded cache size | Can't attend past window |
| Prefix caching | Shared prefixes | None |

## Memory Debugging

### Monitoring Tools

```python
# Current memory usage
print(f"Allocated: {torch.cuda.memory_allocated() / 1e9:.1f} GB")
print(f"Reserved:  {torch.cuda.memory_reserved() / 1e9:.1f} GB")
print(f"Max allocated: {torch.cuda.max_memory_allocated() / 1e9:.1f} GB")

# Memory snapshot for detailed analysis
torch.cuda.memory._record_memory_history()
# ... run training step ...
torch.cuda.memory._dump_snapshot("memory_snapshot.pickle")
# Visualize with torch.cuda.memory_viz
```

### Common OOM Solutions (ordered by ease)

1. **Reduce batch size** (simplest, least impact)
2. **Enable gradient checkpointing** (moderate slowdown)
3. **Use bf16/fp16** (usually free quality-wise)
4. **Reduce sequence length** (if possible for task)
5. **Use LoRA instead of full fine-tuning** (fewer trainable params)
6. **Enable FSDP/DeepSpeed** (requires multi-GPU)
7. **CPU offloading** (significant slowdown)
8. **Use smaller model** (quality trade-off)

### Memory Budget Template

```text
Available VRAM: [X] GB
Model params:   [N] params × [B] bytes = [P] GB
Gradients:      [N] × [B] = [G] GB
Optimizer:      [N] × 12 = [O] GB (AdamW, LoRA: only adapter params)
Activations:    Estimated [A] GB (with/without checkpointing)
KV cache:       [C] GB (if inference)
Total needed:   [P+G+O+A] GB
Headroom:       [Available - Total] GB (need > 0)
```text
