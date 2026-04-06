# Distributed Training Reference

Configuration and patterns for multi-GPU and multi-node training.

## Strategy Selection

```text
Model fits on 1 GPU?
├── Yes → DDP (fastest, simplest)
│         └── But want LoRA? → Single GPU LoRA (often sufficient)
└── No →
    Model fits on 1 node (8 GPUs)?
    ├── Yes → FSDP FULL_SHARD or DeepSpeed ZeRO-3
    └── No → Multi-node FSDP or DeepSpeed with tensor parallelism
```

## DDP (DistributedDataParallel)

- **How**: Replicate model on each GPU, sync gradients via all-reduce
- **Memory**: No savings (full model copy per GPU)
- **Communication**: Gradient all-reduce (overlapped with backward pass)
- **When**: Model + optimizer + activations fit on single GPU

```python
import torch.distributed as dist
from torch.nn.parallel import DistributedDataParallel as DDP

dist.init_process_group("nccl")
model = DDP(model.to(local_rank), device_ids=[local_rank])
```

### DDP Launch

```bash
torchrun --nproc_per_node=8 --nnodes=1 train.py
```

## FSDP (Fully Sharded Data Parallel)

- **How**: Shard model parameters, gradients, and optimizer states across GPUs
- **Memory**: Near-linear reduction with GPU count
- **Communication**: All-gather (forward), reduce-scatter (backward)
- **When**: Model too large for single GPU, used in moshi-finetune

### Memory Comparison (7B model, 8 GPUs)

| Component | DDP (per GPU) | FSDP (per GPU) |
| ----------- | -------------- | ---------------- |
| Parameters (bf16) | 14 GB | 1.75 GB |
| Gradients (bf16) | 14 GB | 1.75 GB |
| Optimizer (fp32) | 28 GB | 3.5 GB |
| **Total** | **56 GB** | **7 GB** |

### FSDP Auto-Wrap Policy

```python
from torch.distributed.fsdp.wrap import transformer_auto_wrap_policy
from functools import partial

# Wrap each transformer layer as a separate FSDP unit
auto_wrap_policy = partial(
    transformer_auto_wrap_policy,
    transformer_layer_cls={TransformerBlock},
)
```

### FSDP Checkpointing

```python
from torch.distributed.fsdp import FullStateDictConfig, StateDictType

# Save full state dict (for export)
with FSDP.state_dict_type(model, StateDictType.FULL_STATE_DICT):
    state_dict = model.state_dict()
    if rank == 0:
        torch.save(state_dict, "checkpoint.pt")

# Save sharded state dict (for resume, faster)
with FSDP.state_dict_type(model, StateDictType.SHARDED_STATE_DICT):
    state_dict = model.state_dict()
    dist_cp.save(state_dict, checkpoint_id=f"checkpoint_step_{step}")
```

## DeepSpeed ZeRO

### ZeRO Stages

| Stage | What's Sharded | Memory Savings | Communication |
| ------- | --------------- | --------------- | --------------- |
| ZeRO-1 | Optimizer states | ~4× | Same as DDP |
| ZeRO-2 | + Gradients | ~8× | Reduce-scatter |
| ZeRO-3 | + Parameters | ~N× (N=GPUs) | All-gather + reduce-scatter |

### ZeRO-3 Config

```json
{
  "zero_optimization": {
    "stage": 3,
    "offload_optimizer": {"device": "cpu"},
    "offload_param": {"device": "none"},
    "overlap_comm": true,
    "contiguous_gradients": true,
    "reduce_bucket_size": 5e7,
    "stage3_prefetch_bucket_size": 5e7,
    "stage3_param_persistence_threshold": 1e5
  },
  "bf16": {"enabled": true},
  "gradient_clipping": 1.0,
  "train_batch_size": "auto",
  "train_micro_batch_size_per_gpu": "auto"
}
```

## Multi-Node Training

### Network Requirements

| Workload | Min Bandwidth | Recommended |
| ---------- | ------------- | ------------- |
| DDP (small model) | 10 Gbps Ethernet | 25 Gbps |
| FSDP (7B) | 100 Gbps | InfiniBand NDR (400 Gbps) |
| FSDP (70B+) | 400 Gbps InfiniBand | NVLink + InfiniBand |

### NCCL Environment Variables

```bash
export NCCL_DEBUG=INFO
export NCCL_IB_DISABLE=0           # Enable InfiniBand
export NCCL_NET_GDR_LEVEL=5        # GPU Direct RDMA
export NCCL_SOCKET_IFNAME=eth0     # Network interface
export NCCL_P2P_LEVEL=NVL          # NVLink P2P
```

### Multi-Node Launch

```bash
# Node 0 (master)
torchrun --nproc_per_node=8 --nnodes=2 --node_rank=0 \
  --master_addr=node0 --master_port=29500 train.py

# Node 1
torchrun --nproc_per_node=8 --nnodes=2 --node_rank=1 \
  --master_addr=node0 --master_port=29500 train.py
```

## Gradient Accumulation

Simulate larger batch sizes without more memory:

```python
accumulation_steps = 8
optimizer.zero_grad()

for i, batch in enumerate(dataloader):
    loss = model(batch).loss / accumulation_steps
    loss.backward()

    if (i + 1) % accumulation_steps == 0:
        torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm=1.0)
        optimizer.step()
        optimizer.zero_grad()
```

**Effective batch size** = micro_batch × GPUs × accumulation_steps

## Performance Debugging

| Symptom | Likely Cause | Fix |
| --------- | ------------- | ----- |
| Low GPU utilization | DataLoader bottleneck | More workers, pin_memory, prefetch |
| Communication overhead | Slow interconnect | Overlap comm/compute, HYBRID_SHARD |
| OOM on forward pass | Activations too large | Gradient checkpointing |
| OOM on backward pass | Gradient accumulation | Reduce micro_batch, use FSDP |
| Slow all-reduce | Large gradient buffers | Bucket size tuning, compression |
