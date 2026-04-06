---
name: model-inference
description: "**WORKFLOW SKILL** — Inference optimization: serving (vLLM, TGI, Triton), quantization (int8/GPTQ/AWQ/GGUF), streaming, batching, KV cache, MoE inference (expert slicing, sparse dispatch, DeepSpeed-Inference MoE mode), edge deployment, and open-weight model-family routing. USE FOR: deploying models to production, optimizing latency, quantizing models, setting up serving infrastructure, deploying MoE models with expert slicing, and choosing practical serving targets across recent open-weight families. USE WHEN: deploying a trained model, optimizing inference speed, choosing a serving framework, serving sparse MoE models, or narrowing model candidates by hardware envelope."
argument-hint: "Describe the inference task: model, target latency, hardware, throughput requirements"
---

# Model Inference

Optimize and deploy ML models for production inference with target latency and throughput.

## When to Use

- Deploying a trained model to production
- Optimizing inference latency or throughput
- Choosing and applying quantization methods
- Setting up a model serving infrastructure
- Implementing streaming inference (audio, text)
- Deploying to edge devices or CPU-only environments
- Choosing between recent open-weight families for a serving target (DeepSeek, Qwen, Gemma, Nemotron, MiniMax, Olmo, Liquid, Mistral)

## Core Concepts

| Concept | Description |
| --------- | ------------- |
| **Quantization** | Reduce precision (FP32 → INT8/INT4) to save memory and speed up |
| **KV Cache** | Cache key/value tensors for autoregressive generation |
| **Continuous Batching** | Dynamically batch requests for throughput |
| **PagedAttention** | Virtual memory for KV cache (vLLM) |
| **Speculative Decoding** | Draft model + verify for faster generation |
| **Family Routing** | Select the right model family first using hardware, license, modality, and serving constraints |
| **Operator Fusion** | Combine kernels to reduce memory transfers |
| **CUDA Graphs** | Record and replay GPU operations to eliminate CPU overhead |

## Procedure

### Phase 1: Model Profiling

1. **Measure** baseline latency (p50, p95, p99)
2. **Profile** with torch.profiler or nsight: identify bottlenecks
3. **Calculate** memory requirements: model weights + KV cache + activations
4. **Determine** throughput: max concurrent requests at target latency

### Phase 2: Quantization

Choose method based on constraints:

| Method | Precision | Quality Impact | Speed | Hardware | Calibration |
| -------- | ----------- | --------------- | ------- | ---------- | ------------- |
| **FP16/BF16** | 16-bit | Negligible | 2× vs FP32 | Any GPU | None |
| **INT8 (torchao)** | W8A8 | < 1% | 2-3× vs FP16 | Ampere+ | Activation stats |
| **GPTQ** | W4A16 | 1-3% | 2-4× vs FP16 | GPU only | Calibration dataset |
| **AWQ** | W4A16 | < 1% | 2-4× vs FP16 | GPU only | Activation-aware |
| **GGUF** | 2-8 bit | Varies | CPU-friendly | CPU / GPU | imatrix calibration |
| **SmoothQuant** | W8A8 | < 1% | 2-3× vs FP16 | Ampere+ | Smoothing factor |

### Phase 3: Serving Framework Selection

| Framework | Best For | Key Features |
| ----------- | ---------- | ------------- |
| **vLLM** | LLM serving (high throughput) | PagedAttention, continuous batching, speculative decoding |
| **TGI** | HuggingFace models | Tensor parallel, quantization, streaming |
| **Triton** | Multi-framework, multi-model | Dynamic batching, model ensemble, NVIDIA |
| **FastAPI + torch** | Custom models | Full control, WebSocket streaming |
| **ONNX Runtime** | Cross-platform | CPU/GPU/NPU, mobile, edge |
| **Rust / Candle** | Low-latency production | Moshi backend pattern |
| **MLX** | Apple Silicon | Native Metal acceleration |
| **llama.cpp** | CPU/edge | GGUF format, cross-platform |
| **DeepSpeed-Inference (MoE)** | MoE model serving | Expert slicing across GPUs, process-group all-to-all dispatch. See `skills/cutting-edge-architectures/references/moe-sparse-routing.md` |

### Phase 3.5: Open-Weight Family Routing

When the exact checkpoint is not fixed yet, use `../_shared/references/llm-landscape.md` first.

| Deployment Envelope | Recommended Starting Points | Detailed Reference |
| ------------------- | -------------------------- | ------------------ |
| CPU / mobile | LFM2.5-1.2B-Thinking, Ministral 3 3B, Tiny Aya | `../_shared/references/models/edge-small.md` |
| 1 x 16-24 GB GPU | DeepSeek-R1 distill 7B / 14B, TranslateGemma 12B, Olmo 3 7B | `../_shared/references/llm-landscape.md` |
| 1 x 48-80 GB GPU | Gemma 4 31B, Olmo 3.1 32B, Nemotron-3-Nano-30B-A3B, GLM-4.7-Flash | `../_shared/references/llm-landscape.md` |
| 2-4 x 80 GB GPUs | MiniMax M2.5 quantized, Qwen3-Coder-Next, Devstral 2 | `../_shared/references/llm-landscape.md` |
| Cluster | DeepSeek V3.2, Kimi K2.5, GLM-5, Qwen3.5 397B-A17B | `../_shared/references/llm-landscape.md` |

### Phase 4: Streaming (Audio/Real-time)

For real-time audio (reference: Kyutai/Moshi pattern):

```text
Input Audio → Ring Buffer → Mimi Encoder (12.5 Hz) → LM (Moshi) → Mimi Decoder → Output Audio
                                                   ↕
                                              KV Cache (per session)
```

Key considerations:
- Frame rate: 12.5 Hz (80ms per frame for Mimi)
- WebSocket transport for bidirectional streaming
- Ring buffer for input accumulation
- Per-session KV cache management
- Graceful handling of connection drops

### Phase 5: Deployment

1. **Containerize**: GPU-capable Docker image (NVIDIA base)
2. **Configure**: Batch size, max concurrent, memory limits
3. **Health checks**: Model loaded, CUDA available, latency probes
4. **Autoscale**: GPU utilization-based scaling
5. **Monitor**: Latency SLOs, error rates, GPU memory usage

## Kyutai Open-Source Reference — Inference

| Project | Framework | Optimization | Notes |
| --------- | ----------- | ------------- | ------- |
| Moshi (Rust) | Candle | Custom CUDA kernels | WebSocket streaming |
| Moshi (Python) | PyTorch + torchao | INT8 quantization | `export_quantized.py` |
| Moshi (MLX) | MLX | Apple Silicon native | `moshi_mlx/` |
| Pocket-TTS | PyTorch / ONNX | CPU-targeted | Lightweight |
| Unmute | Docker + FastAPI | Multi-model routing | Docker Compose |

## Benchmark Template

```text
Model: [name, params, format]
Hardware: [GPU model, count, driver version]
Quantization: [method, calibration details]
Results:
  Latency (p50): X ms
  Latency (p95): X ms
  Latency (p99): X ms
  Throughput: X req/s
  Memory: X GB
  Quality: [metric name] = X (vs baseline Y, delta Z%)
```
