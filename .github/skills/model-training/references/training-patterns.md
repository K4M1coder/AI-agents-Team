# Training Patterns Reference

Reusable patterns for ML model training configurations.

## Pattern 1: LoRA Fine-Tuning (Reference: Kyutai moshi-finetune)

From moshi-finetune configuration:

```yaml
# moshi-finetune/example/moshi_7B.yaml pattern
model:
  name: moshi_7b
  checkpoint: kyutai/moshi-7b

training:
  epochs: 3
  batch_size: 4
  gradient_accumulation_steps: 8  # effective batch = 32
  learning_rate: 2e-4
  weight_decay: 0.01
  warmup_steps: 100
  max_grad_norm: 1.0
  precision: bf16

lora:
  rank: 64
  alpha: 128
  target_modules: [q_proj, v_proj, k_proj, o_proj, gate_proj, up_proj, down_proj]
  dropout: 0.05

distributed:
  strategy: fsdp
  sharding_strategy: FULL_SHARD

logging:
  wandb_project: moshi-finetune
  log_interval: 10
  eval_interval: 500
  save_interval: 1000
```

### LoRA Rank Selection Guide

| Rank | Params Added | Quality | Use Case |
| ------ | ------------- | --------- | ---------- |
| 8 | ~0.1% of model | Basic adaptation | Simple tasks, limited data |
| 16 | ~0.2% | Good for most tasks | Default starting point |
| 32 | ~0.4% | Near full fine-tune quality | Complex tasks |
| 64 | ~0.8% | Best quality | Kyutai default, rich data |
| 128 | ~1.6% | Diminishing returns | Very complex adaptations |

---

## Pattern 2: Full Fine-Tuning (Small Models)

For models < 1B parameters where full fine-tuning is tractable:

```yaml
training:
  epochs: 5-10
  batch_size: 32
  learning_rate: 5e-5  # lower than LoRA
  weight_decay: 0.1
  warmup_ratio: 0.1
  lr_scheduler: cosine
  precision: bf16
  gradient_checkpointing: true

optimizer:
  name: adamw
  betas: [0.9, 0.95]
  eps: 1e-8
```

---

## Pattern 3: FSDP Configuration

```python
from torch.distributed.fsdp import FullyShardedDataParallel as FSDP
from torch.distributed.fsdp import ShardingStrategy, MixedPrecision

fsdp_config = {
    "sharding_strategy": ShardingStrategy.FULL_SHARD,
    "mixed_precision": MixedPrecision(
        param_dtype=torch.bfloat16,
        reduce_dtype=torch.bfloat16,
        buffer_dtype=torch.bfloat16,
    ),
    "auto_wrap_policy": transformer_auto_wrap_policy,
    "activation_checkpointing": True,
    "forward_prefetch": True,
    "limit_all_gathers": True,
}
```

### FSDP Sharding Strategies

| Strategy | Memory | Communication | Use Case |
| ---------- | -------- | -------------- | ---------- |
| FULL_SHARD | Lowest | Highest | Default, large models |
| SHARD_GRAD_OP | Medium | Medium | When bandwidth > memory |
| NO_SHARD | Highest (DDP) | Lowest | Small models |
| HYBRID_SHARD | Balanced | Balanced | Multi-node (shard within node) |

---

## Pattern 4: Learning Rate Schedules

### Cosine with Warmup (Most Common)

```python
from torch.optim.lr_scheduler import CosineAnnealingLR

# Warmup: linear ramp from 0 to lr over warmup_steps
# Decay: cosine from lr to min_lr over remaining steps
scheduler = CosineAnnealingLR(optimizer, T_max=total_steps, eta_min=min_lr)
```

### Warmup-Stable-Decay (WSD)

```text
r = lr_max during [warmup_end, decay_start]
     then cosine decay to lr_min
Good for long training runs where you want stable lr for most of training.
```

### Key Parameters

| Parameter | Typical Value | Notes |
| ----------- | -------------- | ------- |
| Peak LR | 1e-4 to 3e-4 (from scratch), 1e-5 to 5e-5 (fine-tune) | Scale with √batch_size |
| Min LR | 1e-5 to 1e-6 | 10× lower than peak |
| Warmup | 1-10% of total steps | Higher for larger LR |
| Weight decay | 0.01-0.1 | Exclude bias and norm params |

---

## Pattern 5: Evaluation During Training

```python
@torch.no_grad()
def evaluate(model, eval_dataloader, device):
    model.eval()
    total_loss = 0
    total_tokens = 0

    for batch in eval_dataloader:
        batch = {k: v.to(device) for k, v in batch.items()}
        outputs = model(**batch)
        total_loss += outputs.loss.item() * batch["input_ids"].numel()
        total_tokens += batch["input_ids"].numel()

    model.train()
    return {
        "eval_loss": total_loss / total_tokens,
        "eval_perplexity": math.exp(total_loss / total_tokens),
    }
```

### Evaluation Frequency

| Training Duration | Eval Interval |
| ------------------ | --------------- |
| < 1000 steps | Every 100 steps |
| 1000-10000 steps | Every 500 steps |
| > 10000 steps | Every 1000 steps |
| Fine-tuning | Every epoch |

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| ------------- | --------- | ----- |
| No warmup | Unstable early training | Always warm up (1-10%) |
| LR too high for fine-tuning | Catastrophic forgetting | Use 10-100× lower LR than pre-training |
| No gradient clipping | Exploding gradients | max_norm=1.0 |
| FP16 without loss scaling | NaN/underflow | Use bf16 (no scaling needed) or AMP |
| No eval during training | Can't detect overfitting | Eval every N steps |
| Saving only last checkpoint | Lost best model | Save best + periodic |
