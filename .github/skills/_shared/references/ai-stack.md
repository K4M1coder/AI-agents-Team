# AI/ML Stack Reference

Cross-cutting reference for all AI/MLOps agents and skills. Maps frameworks, tools, hardware, and patterns by use case.

## How to Use This Reference

- Use this file to map tasks to frameworks, runtime stacks, registries, quantization methods, hardware classes, and architecture building blocks.
- Use it when the question is about tooling or stack composition rather than model-family choice.

## Boundaries

- Model-family routing belongs in `llm-landscape.md` and the files under `models/`.
- Environment, platform, and IaC surface-area mapping belongs in `environments.md`.
- Skill-specific implementation detail still belongs in the specialist skills themselves.

## Frameworks & Libraries

### Training

| Framework | Use Case | Notes |
| ----------- | ---------- | ------- |
| **PyTorch** | Research & production training | Primary framework; widely used in audio AI stacks (e.g., Kyutai: Moshi, Mimi, Pocket-TTS) |
| **PyTorch Lightning** | Structured training loops | Callbacks, logging, checkpointing |
| **DeepSpeed** | Distributed training (ZeRO-1/2/3) | Memory-efficient large model training |
| **FSDP** | Fully Sharded Data Parallel | Used in moshi-finetune |
| **Hugging Face Transformers** | Pre-trained model hub + Trainer API | Fine-tuning, evaluation |
| **JAX / Flax** | Functional ML, TPU-optimized | Google ecosystem |
| **MLX** | Apple Silicon native training/inference | Used in moshi_mlx |

### Inference

| Framework | Use Case | Notes |
| ----------- | ---------- | ------- |
| **vLLM** | High-throughput LLM serving | PagedAttention, continuous batching |
| **TGI (Text Generation Inference)** | HuggingFace model serving | Tensor parallelism, quantization |
| **Triton Inference Server** | Multi-framework model serving | NVIDIA, dynamic batching |
| **ONNX Runtime** | Cross-platform inference | CPU/GPU/NPU optimization |
| **TensorRT** | NVIDIA GPU-optimized inference | INT8/FP16 acceleration |
| **Rust / Candle** | Low-latency production inference | Used in Moshi rust backend |
| **llama.cpp / GGUF** | CPU/edge inference | Quantized format, cross-platform |

### Audio/Speech AI Stack

| Component | Project | Purpose |
| ----------- | ---------- | ------- |
| **Moshi** | `moshi/` | 7B/2B speech-text dialogue model |
| **Mimi** | `moshi/rust/moshi-core` | Neural audio codec (12.5Hz, 1.1kbps, RVQ) |
| **Pocket-TTS** | `pocket-tts/` | Lightweight CPU text-to-speech |
| **Hibiki** | `hibiki/` | Speech-to-speech translation |
| **Unmute** | `unmute/` | Multi-model orchestrator, API serving |
| **LSD (Latent Speech Diffusion)** | Flow matching for speech | arxiv:2505.18825 |

---

## Quantization Methods

| Method | Precision | Framework | Notes |
| -------- | ----------- | ----------- | ------- |
| **torchao int8** | W8A8 | PyTorch | Used in Moshi (`export_quantized.py`) |
| **GPTQ** | W4A16 / W3A16 | AutoGPTQ | Post-training, GPU-only |
| **AWQ** | W4A16 | AutoAWQ | Activation-aware, faster than GPTQ |
| **GGUF** | 2-8 bit mixed | llama.cpp | CPU-friendly, imatrix calibration |
| **bitsandbytes** | 4/8-bit | PyTorch | QLoRA via NF4 |
| **SmoothQuant** | W8A8 | Various | Activation smoothing for LLMs |

---

## Experiment Tracking & Model Registry

| Tool | Purpose | Notes |
| ----------- | ---------- | ------- |
| **Weights & Biases (W&B)** | Experiment tracking, sweeps | Used in moshi-finetune |
| **MLflow** | Tracking + model registry + serving | Open-source, self-hosted |
| **TensorBoard** | Training visualization | Used in moshi-finetune |
| **Hugging Face Hub** | Model hosting, versioning, datasets | Model hosting; Kyutai open-source models available at huggingface.co/kyutai |
| **DVC** | Data versioning | Git-like for large files |

---

## Hardware

### GPUs

| GPU | VRAM | Use Case | Notes |
| ----- | ------ | ---------- | ------- |
| **NVIDIA H100 SXM** | 80 GB HBM3 | Training (large models) | FP8 Transformer Engine |
| **NVIDIA A100 SXM** | 80 GB HBM2e | Training + inference | Standard datacenter GPU |
| **NVIDIA L40S** | 48 GB GDDR6 | Inference + light training | Good price/performance |
| **NVIDIA RTX 4090** | 24 GB GDDR6X | Dev/research | Consumer, no NVLink |
| **AMD MI300X** | 192 GB HBM3 | Training | ROCm ecosystem |
| **Apple M-series** | Unified (up to 192 GB) | MLX inference/training | Used in moshi_mlx |

### Interconnect

| Technology | Bandwidth | Use Case |
| ----------- | ---------- | ------- |
| **NVLink** | 900 GB/s (H100) | Intra-node GPU-GPU |
| **NVSwitch** | Full bisection | All-to-all within node |
| **InfiniBand NDR** | 400 Gbps | Inter-node RDMA |
| **RoCE v2** | 100-400 Gbps | Ethernet RDMA alternative |
| **NCCL** | N/A (library) | NVIDIA collective comms |

### Cloud GPU Providers

| Provider | Instances | Notes |
| ----------- | ---------- | ------- |
| **AWS** | p5 (H100), p4d (A100), g5 (A10G), inf2 (Inferentia2) | Spot up to 90% savings |
| **GCP** | a3 (H100), a2 (A100), TPU v5p | Best TPU access |
| **Azure** | ND H100 v5, NC A100 v4 | Azure ML integration |
| **Lambda Labs** | On-demand H100/A100 | Simple, no commitment |
| **CoreWeave** | H100/A100/L40S | GPU-native cloud |
| **RunPod / Vast.ai** | Community GPUs | Cheapest, variable quality |

---

## Data Tools

| Tool | Purpose | Notes |
| ----------- | ---------- | ------- |
| **Hugging Face Datasets** | Dataset loading, processing | Streaming, memory-mapped |
| **webdataset** | Streaming large-scale datasets | Tar-based shards |
| **LabelStudio** | Data labeling | Open-source, multi-modal |
| **Prodigy** | Annotation (NLP-focused) | Spacy ecosystem |
| **DVC** | Data/model versioning | S3/GCS/Azure backends |
| **Great Expectations** | Data validation | Quality checks, profiling |
| **librosa / torchaudio** | Audio processing | Feature extraction, transforms |

---

## Architecture Building Blocks

| Block | Description | Examples |
| ----------- | ---------- | ------- |
| **Multi-Head Attention (MHA)** | Parallel attention heads | Transformer standard |
| **Grouped Query Attention (GQA)** | Shared KV heads | Llama 2/3, Mistral |
| **Multi-Query Attention (MQA)** | Single KV head | PaLM, Falcon |
| **RoPE** | Rotary Position Embedding | Used in Moshi (arxiv:2104.09864) |
| **RMSNorm** | Root Mean Square normalization | Llama, Moshi |
| **SwiGLU** | Gated activation function | Llama, Moshi |
| **Residual Connections** | Skip connections | All modern architectures |
| **Residual VQ (RVQ)** | Multi-codebook quantization | Mimi codec |
| **Depformer** | Depth transformer for codebooks | Moshi (arxiv:2410.00037) |
| **Flow Matching** | Continuous normalizing flows | LSD speech generation |

---

## Related Shared References

- `llm-landscape.md` — model-family routing and deployment selection
- `environments.md` — OS, virtualization, cloud, and IaC environment matrix
