# GPU Selection Reference

Detailed comparison of GPU options for ML training and inference.

## NVIDIA GPUs

### Datacenter GPUs

| GPU | VRAM | Memory BW | FP16 TFLOPS | FP8 TFLOPS | NVLink | TDP | Price (cloud/hr) |
| ----- | ------ | ----------- | ------------- | ------------ | -------- | ----- | ----------------- |
| **H100 SXM** | 80 GB HBM3 | 3.35 TB/s | 989 | 1979 | 900 GB/s | 700W | $3-5 |
| **H100 PCIe** | 80 GB HBM3 | 2.0 TB/s | 756 | 1513 | No | 350W | $2-4 |
| **A100 SXM** | 80 GB HBM2e | 2.0 TB/s | 312 | N/A | 600 GB/s | 400W | $1.5-3 |
| **A100 PCIe** | 80 GB HBM2e | 2.0 TB/s | 312 | N/A | No | 300W | $1.2-2.5 |
| **L40S** | 48 GB GDDR6 | 864 GB/s | 362 | 733 | No | 350W | $1-2 |
| **L4** | 24 GB GDDR6 | 300 GB/s | 121 | 242 | No | 72W | $0.5-1 |
| **T4** | 16 GB GDDR6 | 320 GB/s | 65 | N/A | No | 70W | $0.3-0.5 |

### Consumer GPUs

| GPU | VRAM | Memory BW | FP16 TFLOPS | NVLink | TDP | Notes |
| ----- | ------ | ----------- | ------------- | -------- | ----- | ------- |
| **RTX 4090** | 24 GB GDDR6X | 1.0 TB/s | 330 | No | 450W | Best consumer, no NVLink |
| **RTX 4080** | 16 GB GDDR6X | 717 GB/s | 206 | No | 320W | Good mid-range |
| **RTX 3090** | 24 GB GDDR6X | 936 GB/s | 142 | NVLink | 350W | Still capable |
| **RTX 5090** | 32 GB GDDR7 | 1.8 TB/s | ~400 | No | 575W | Latest gen |

## AMD GPUs

| GPU | VRAM | Memory BW | FP16 TFLOPS | Notes |
| ----- | ------ | ----------- | ------------- | ------- |
| **MI300X** | 192 GB HBM3 | 5.3 TB/s | 1300 | Massive VRAM, ROCm |
| **MI250X** | 128 GB HBM2e | 3.2 TB/s | 383 | Multi-die |

**ROCm ecosystem**: Growing but less mature than CUDA. PyTorch support good, some custom kernels missing.

## Apple Silicon

| Chip | Unified Memory | Memory BW | Neural Engine | Best For |
| ------ | --------------- | ----------- | -------------- | ---------- |
| **M4 Max** | up to 128 GB | 546 GB/s | 38 TOPS | MLX inference, dev |
| **M4 Ultra** | up to 512 GB | 800 GB/s | 76 TOPS | Large model inference |
| **M3 Max** | up to 128 GB | 400 GB/s | 18 TOPS | MLX inference |

**Key advantage**: Unified memory allows loading models larger than typical VRAM.
**Framework**: MLX (used in moshi_mlx)

## Decision Matrix

### Training

| Scenario | Recommended GPU | Min Count | Config |
| ---------- | ---------------- | ----------- | -------- |
| Fine-tune < 1B | RTX 4090 | 1 | LoRA, single GPU |
| Fine-tune 1-7B | A100 80GB | 1-2 | LoRA/QLoRA |
| Fine-tune 7B full | A100 80GB | 4-8 | FSDP |
| Train 7B from scratch | H100 SXM | 8-64 | FSDP + NVLink |
| Train 70B | H100 SXM | 64-512 | 3D parallelism + InfiniBand |

### Inference

| Scenario | Recommended GPU | Count | Config |
| ---------- | ---------------- | ------- | -------- |
| Serve < 1B | T4 / L4 | 1 | INT8 |
| Serve 1-7B | L40S / A10G | 1 | INT8 / AWQ |
| Serve 7-13B | A100 / L40S | 1 | AWQ / GPTQ |
| Serve 70B | A100 / H100 | 2-4 | Tensor parallel + quantization |
| Real-time audio | L40S / A100 | 1 | Custom kernels (Moshi pattern) |

## Cloud Provider Comparison

### AWS

| Instance | GPU | Count | VRAM Total | On-Demand/hr | Spot/hr |
| ---------- | ----- | ------- | ----------- | ------------- | --------- |
| p5.48xlarge | H100 SXM | 8 | 640 GB | ~$98 | ~$30-40 |
| p4d.24xlarge | A100 SXM | 8 | 640 GB | ~$32 | ~$10-15 |
| g5.xlarge | A10G | 1 | 24 GB | ~$1.0 | ~$0.3 |
| g6.xlarge | L4 | 1 | 24 GB | ~$0.8 | ~$0.25 |
| inf2.xlarge | Inferentia2 | 1 | 32 GB | ~$0.75 | ~$0.3 |

### GCP

| Instance | GPU | Count | On-Demand/hr |
| ---------- | ----- | ------- | ------------- |
| a3-highgpu-8g | H100 | 8 | ~$98 |
| a2-highgpu-1g | A100 | 1 | ~$3.7 |
| g2-standard-4 | L4 | 1 | ~$0.7 |

### Budget Options

| Provider | GPU | Hourly Cost | Notes |
| ---------- | ----- | ------------- | ------- |
| Lambda Labs | A100 80GB | ~$1.1 | Simple, reliable |
| RunPod | A100 80GB | ~$1.6 | Community cloud |
| Vast.ai | A100 80GB | ~$0.8-1.5 | Cheapest, variable |
| CoreWeave | H100 SXM | ~$2.2 | GPU-native cloud |

## Cost Optimization Strategies

1. **Spot/preemptible instances**: 50-80% savings, need checkpoint management
2. **Right-sizing**: Don't use H100 for inference that fits on L4
3. **Reserved capacity**: 1-3 year commitments for 30-60% savings
4. **Mixed precision**: BF16 training doubles throughput for free
5. **Quantization**: INT8/INT4 inference cuts GPU cost 2-4×
6. **Batch scheduling**: Accumulate requests for better GPU utilization
7. **Time-of-day pricing**: Some providers offer off-peak discounts
