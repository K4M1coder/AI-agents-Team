---
name: model-training
description: "**WORKFLOW SKILL** — Training & fine-tuning: PyTorch training loops, distributed training (FSDP/DDP/DeepSpeed), MoE training (DeepSpeed-MoE, expert parallelism), LoRA/QLoRA, mixed precision, hyperparameter tuning, curriculum learning, and open-weight baseline selection. USE FOR: writing training code, configuring distributed training, fine-tuning pre-trained models, debugging training issues, selecting current open-weight baselines, and training sparse MoE models with expert parallelism. USE WHEN: training a model from scratch, fine-tuning, debugging loss curves, scaling to multiple GPUs, choosing a family-specific base model, or configuring MoE expert routing and load balance."
argument-hint: "Describe the training task: model, dataset, hardware, target metrics"
---

# Model Training

Train and fine-tune ML models with PyTorch, from single-GPU to multi-node distributed.

## When to Use

- Writing or modifying training loops
- Configuring distributed training (FSDP, DDP, DeepSpeed)
- Fine-tuning pre-trained models (LoRA, QLoRA, full)
- Debugging training issues (loss spikes, NaN, slow convergence)
- Optimizing training speed and memory usage
- Choosing a current open-weight base model or distill before fine-tuning

## Core Concepts

| Concept | Description |
| --------- | ------------- |
| **Training Loop** | Forward → loss → backward → optimizer step → log |
| **Mixed Precision** | bf16/fp16 forward pass, fp32 master weights |
| **Gradient Accumulation** | Simulate larger batch size across steps |
| **Gradient Checkpointing** | Recompute activations to save memory |
| **Learning Rate Schedule** | Warmup → cosine/linear decay |
| **LoRA** | Low-rank adapters, train only adapter weights |
| **FSDP** | Shard parameters, gradients, optimizer across GPUs |

## Procedure

### Phase 1: Setup

1. **Choose** the baseline family and checkpoint class using `../_shared/references/llm-landscape.md` when the model choice is still open
2. **Verify** hardware: GPU count, VRAM, interconnect
3. **Configure** environment: CUDA, NCCL, PyTorch version
4. **Load** data: DataLoader with proper workers, prefetching, pinned memory
5. **Initialize** model: from pretrained or random init
6. **Choose** precision: bf16 (preferred on Ampere+), fp16 (with loss scaling)

### Phase 2: Training Configuration

1. **Optimizer**: AdamW (default), Lion, Adafactor for memory efficiency
2. **Learning Rate**: 1e-4 to 5e-5 for fine-tuning, 1e-3 to 3e-4 for from-scratch
3. **Batch Size**: Largest that fits in memory × gradient accumulation steps
4. **Warmup**: 5-10% of total steps
5. **Weight Decay**: 0.01-0.1 (exclude biases and LayerNorm)
6. **Gradient Clipping**: max_norm=1.0

### Phase 3: Distributed Training

Choose strategy based on model size:

| Strategy | Model Size | GPU Count | Memory Savings |
| ---------- | ----------- | ----------- | --------------- |
| **DDP** | Fits on 1 GPU | 2-8 | None (replication) |
| **FSDP** | Too large for 1 GPU | 2-128+ | Shard params + grads + optimizer |
| **DeepSpeed ZeRO-2** | Large models | 2-64 | Shard grads + optimizer |
| **DeepSpeed ZeRO-3** | Very large models | 8-256+ | Full sharding (like FSDP) |
| **DeepSpeed-MoE** | MoE models | 8-256+ | Expert parallelism (ep_size), capacity_factor, load balance loss. See `skills/cutting-edge-architectures/references/moe-sparse-routing.md` |
| **LoRA** | Any pretrained model | 1+ | Train only adapters (~1% params) |

### Phase 4: Fine-Tuning Specifics

**LoRA Configuration (reference: Kyutai moshi-finetune):**
```yaml
lora:
  rank: 64
  alpha: 128  # typically 2× rank
  target_modules: [q_proj, v_proj, k_proj, o_proj, gate_proj, up_proj, down_proj]
  dropout: 0.05
```

**Full Fine-Tuning:**
- Lower learning rate (1e-5 to 5e-6)
- Shorter training (1-3 epochs)
- Careful evaluation frequency to detect overfitting

### Phase 5: Monitoring & Debugging

**Healthy training signals:**
- Loss decreasing smoothly
- Gradient norm stable (not exploding/vanishing)
- Learning rate following schedule
- GPU utilization > 80%

**Common issues and fixes:**

| Issue | Symptom | Fix |
| ------- | --------- | ----- |
| Exploding gradients | Loss → NaN | Gradient clipping, lower LR |
| Vanishing gradients | Loss plateau | Check init, add residual connections |
| OOM | CUDA OOM error | Reduce batch size, enable gradient checkpointing, use FSDP |
| Slow training | Low GPU utilization | Increase DataLoader workers, pin memory, prefetch |
| Overfitting | Val loss increasing | More data, dropout, weight decay, early stopping |
| Underfitting | Both losses high | Larger model, lower regularization, more epochs |

## Kyutai Open-Source Reference — Training

- **moshi-finetune**: LoRA rank 64, FSDP, bf16, W&B + TensorBoard
- **Config format**: YAML (`example/moshi_7B.yaml`)
- **Data format**: JSONL with audio paths
- **Evaluation**: In-training eval on held-out data
- **Checkpointing**: FSDP sharded checkpoints, periodic saves

## Tools Reference

| Tool | Purpose |
| ------ | --------- |
| PyTorch (`torch.distributed`) | DDP, FSDP |
| DeepSpeed | ZeRO optimization |
| PEFT (HuggingFace) | LoRA, QLoRA, adapters |
| W&B | Experiment tracking |
| TensorBoard | Training visualization |
| torch.profiler | Performance profiling |
| torchao | Quantization-aware training |
