---
name: gpu-compute
description: "**WORKFLOW SKILL** — GPU and hardware management: GPU selection, CUDA optimization, memory management, multi-GPU/multi-node, cluster design, cloud GPU provisioning, and sizing recent open-weight model families from edge to frontier clusters. USE FOR: hardware planning, CUDA debugging, memory optimization, cluster configuration, cloud GPU cost analysis, and mapping model families to realistic deployment tiers. USE WHEN: selecting GPUs, debugging CUDA errors, optimizing memory usage, designing training clusters, or estimating hardware for new open-weight releases."
argument-hint: "Describe the hardware task: GPU selection, memory issue, cluster design, or cloud provisioning"
---

# GPU Compute

Select, configure, and optimize GPU hardware for ML training and inference workloads.

## When to Use

- Selecting GPUs for a new project (training or inference)
- Debugging CUDA out-of-memory errors
- Optimizing GPU memory usage
- Designing a multi-GPU training cluster
- Comparing cloud GPU providers and pricing
- Configuring NCCL for distributed training
- Sizing hardware for recent open-weight model families from edge models to frontier MoE deployments

## Core Concepts

| Concept | Description |
| --------- | ------------- |
| **VRAM** | GPU memory for model weights, activations, KV cache |
| **Compute (FLOPS)** | Processing power: FP32, FP16, BF16, INT8, FP8 |
| **Memory Bandwidth** | Data transfer speed (GB/s) — often the bottleneck |
| **Interconnect** | GPU-to-GPU communication (NVLink, PCIe, InfiniBand) |
| **Tensor Cores** | Specialized matrix multiply units (NVIDIA) |
| **CUDA Cores** | General-purpose GPU compute units |

## Procedure

### Phase 1: Workload Analysis

1. **Model size**: Parameter count → memory requirement
2. **Training or inference**: Training needs ~16-20× params bytes, inference ~2× (fp16)
3. **Batch size**: Larger batches need more memory but better GPU utilization
4. **Sequence length**: Affects KV cache size (quadratic for attention)
5. **Throughput requirement**: Requests/second or samples/second
6. **Budget**: Cloud hourly cost vs on-prem TCO

### Phase 2: GPU Selection

Use the decision matrix in `references/gpu-selection.md`.

### Phase 2.5: Open-Weight Family Envelope Selection

If the workload is not fixed to a single checkpoint yet, use `../_shared/references/llm-landscape.md` to choose the family before sizing hardware.

| Deployment Envelope | Candidate Families / Models | Notes |
| ------------------- | --------------------------- | ----- |
| CPU / mobile | LFM2.5-1.2B-Thinking, Ministral 3 3B, Tiny Aya | Low-bit, offline-first |
| 1 x 16-24 GB GPU | DeepSeek-R1 distill 7B / 14B, TranslateGemma 12B, Olmo 3 7B | Local productivity / reasoning |
| 1 x 48-80 GB GPU | Gemma 4 31B, Olmo 3.1 32B, Nemotron-3-Nano-30B-A3B, GLM-4.7-Flash | Strong single-node tier |
| 2-4 x 80 GB GPUs | MiniMax M2.5 quantized, Qwen3-Coder-Next, Devstral 2 | Internal code / agent platforms |
| Multi-node cluster | DeepSeek V3.2, Kimi K2.5, GLM-5, Qwen3.5 397B-A17B, Trinity Large | Requires expert parallel and fast interconnect |

Use `../_shared/references/models/edge-small.md` when the primary constraint is VRAM, offline use, or mobile deployment.

### Phase 3: Configuration

1. **Driver**: Install matching NVIDIA driver + CUDA toolkit
2. **NCCL**: Configure for multi-GPU communication
3. **Environment**: Set CUDA_VISIBLE_DEVICES, NCCL vars
4. **Monitoring**: nvidia-smi, dcgm-exporter, GPU Prometheus metrics

### Phase 4: Optimization

See `references/memory-optimization.md` for techniques.

## Quick Reference: Memory Estimation

```text
Training memory (bf16, AdamW):
  Parameters:  N × 2 bytes (bf16)
  Gradients:   N × 2 bytes (bf16)
  Optimizer:   N × 8 bytes (fp32 momentum + variance)
  Activations: Varies (use gradient checkpointing to reduce)
  Total ≈ N × 12-16 bytes (without activations)
  With FSDP: divide by number of GPUs

Inference memory (fp16):
  Parameters: N × 2 bytes
  KV cache:   2 × n_layers × d_model × seq_len × 2 bytes (per sequence)
  Activations: batch × seq_len × d_model × 2 bytes (temporary)
```

### Example: 7B Model
| Component | Training (bf16) | Inference (fp16) |
| ----------- | ---------------- | ----------------- |
| Parameters | 14 GB | 14 GB |
| Gradients | 14 GB | - |
| Optimizer | 56 GB | - |
| Activations | ~10 GB | ~1 GB |
| KV cache | - | ~2 GB (4k seq) |
| **Total** | **~94 GB** | **~17 GB** |
| With FSDP (8 GPU) | **~12 GB/GPU** | - |

## OOM Diagnostic Procedure

When encountering `CUDA out of memory`, follow this sequence:

```text
Step 1: Identify what's consuming memory
  $ nvidia-smi                         # Check current VRAM usage
  $ python -c "import torch; torch.cuda.memory_summary()"

Step 2: Quick wins (try in order)
  ┌─ Reduce batch_size by 50%
  ├─ Enable gradient checkpointing:
  │    model.gradient_checkpointing_enable()
  ├─ Use bf16/fp16 mixed precision:
  │    torch.autocast("cuda", dtype=torch.bfloat16)
  ├─ Clear cache between steps:
  │    torch.cuda.empty_cache()
  └─ Reduce sequence length or max_position_embeddings

Step 3: If still OOM after quick wins
  ┌─ Enable FSDP (multi-GPU sharding)
  ├─ Use activation offloading (CPU offload)
  ├─ Switch to 8-bit optimizer (bitsandbytes)
  │    import bitsandbytes as bnb
  │    optimizer = bnb.optim.AdamW8bit(model.parameters(), lr=1e-5)
  └─ Use LoRA/QLoRA instead of full fine-tuning

Step 4: Memory leak diagnosis
  torch.cuda.memory._record_memory_history()
  # ... run suspect code ...
  torch.cuda.memory._dump_snapshot("mem_snapshot.pickle")
  # Visualize at https://pytorch.org/memory_viz
```

## GPU Profiling Workflow

### PyTorch Profiler (recommended first step)

```python
from torch.profiler import profile, ProfilerActivity, tensorboard_trace_handler

with profile(
    activities=[ProfilerActivity.CPU, ProfilerActivity.CUDA],
    schedule=torch.profiler.schedule(wait=1, warmup=1, active=3, repeat=1),
    on_trace_ready=tensorboard_trace_handler("./profiler_logs"),
    record_shapes=True,
    profile_memory=True,
    with_stack=True,
) as prof:
    for step, batch in enumerate(dataloader):
        if step >= 6:  # wait(1) + warmup(1) + active(3) + 1
            break
        output = model(batch)
        loss = output.loss
        loss.backward()
        prof.step()

# Print summary
print(prof.key_averages().table(sort_by="cuda_time_total", row_limit=20))
```

### NVIDIA Nsight Systems (full system profiling)

```bash
# Profile a training script (capture CUDA + NCCL + CPU)
nsys profile --trace=cuda,nvtx,osrt,cudnn,cublas \
  --output=training_profile \
  --force-overwrite true \
  python train.py --max-steps 10

# View results
nsys stats training_profile.nsys-rep
```

### Quick Utilization Check

```bash
# Continuous GPU monitoring (1s interval)
nvidia-smi dmon -s pucvmet -d 1

# Memory fragmentation check
python -c "
import torch
print(f'Allocated: {torch.cuda.memory_allocated()/1e9:.2f} GB')
print(f'Reserved:  {torch.cuda.memory_reserved()/1e9:.2f} GB')
print(f'Fragmentation: {1 - torch.cuda.memory_allocated()/torch.cuda.memory_reserved():.1%}')
"
```

## Common CUDA Errors

| Error | Cause | Fix |
| ------- | ------- | ----- |
| `CUDA out of memory` | Not enough VRAM | See OOM Diagnostic Procedure above |
| `NCCL timeout` | Communication failure | Check network, NCCL_DEBUG=INFO |
| `CUDA error: device-side assert` | Invalid tensor operation | Run with CUDA_LAUNCH_BLOCKING=1 |
| `cuDNN error` | Version mismatch | Match PyTorch-CUDA-cuDNN versions |
| `NCCL error: unhandled cuda error` | GPU failure | Check GPU health (nvidia-smi -q) |
