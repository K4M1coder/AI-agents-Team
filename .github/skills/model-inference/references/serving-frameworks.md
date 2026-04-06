# Serving Frameworks Reference

Comparison and configuration of ML model serving frameworks.

## Framework Comparison

| Framework | Best For | Batching | Quantization | Streaming | Multi-Model | GPU |
| ----------- | ---------- | --------- | ------------- | ----------- | ------------ | ----- |
| **vLLM** | LLM serving | Continuous | AWQ, GPTQ, INT8 | SSE/WebSocket | Basic | Required |
| **TGI** | HF models | Continuous | GPTQ, AWQ, EETQ | SSE | Basic | Required |
| **Triton** | Multi-framework | Dynamic | TensorRT, ONNX | gRPC stream | Ensemble | Required |
| **FastAPI+torch** | Custom | Manual | Any | WebSocket | Custom | Optional |
| **Rust/Candle** | Low latency | Custom | Custom | WebSocket | Custom | Optional |
| **ONNX Runtime** | Cross-platform | Session | INT8, FP16 | No | Session | Optional |
| **llama.cpp** | CPU/edge | Token | GGUF | Streaming | No | Optional |
| **MLX** | Apple Silicon | Session | MLX quant | No | Session | Metal |

## vLLM

Best for high-throughput LLM serving.

```python
from vllm import LLM, SamplingParams

llm = LLM(
    model="kyutai/moshi-7b",
    tensor_parallel_size=2,        # 2 GPUs
    dtype="bfloat16",
    max_model_len=8192,
    gpu_memory_utilization=0.90,
)

params = SamplingParams(temperature=0.7, top_p=0.9, max_tokens=512)
outputs = llm.generate(prompts, params)
```

### vLLM Key Features

- **PagedAttention**: Virtual memory for KV cache, minimal waste
- **Continuous batching**: Add/remove requests mid-batch
- **Speculative decoding**: Draft model for faster generation
- **Prefix caching**: Share KV cache for common prefixes
- **Tensor parallelism**: Split model across GPUs

### vLLM API Server

```bash
python -m vllm.entrypoints.openai.api_server \
    --model kyutai/moshi-7b \
    --tensor-parallel-size 2 \
    --port 8000
```

## Triton Inference Server

Best for multi-framework, production-grade serving.

```text
odel_repository/
├── moshi/
│   ├── config.pbtxt
│   └── 1/
│       └── model.onnx
├── mimi_encoder/
│   ├── config.pbtxt
│   └── 1/
│       └── model.plan  # TensorRT
└── ensemble/
    └── config.pbtxt    # Chain models
```

### Triton Config

```protobuf
name: "moshi"
platform: "onnxruntime_onnx"
max_batch_size: 8
input [{name: "input_ids", data_type: TYPE_INT64, dims: [-1]}]
output [{name: "logits", data_type: TYPE_FP32, dims: [-1, -1]}]
dynamic_batching {
    preferred_batch_size: [4, 8]
    max_queue_delay_microseconds: 100
}
instance_group [{count: 2, kind: KIND_GPU}]
```

## FastAPI + PyTorch (Custom Serving)

Best for custom models and streaming (Kyutai pattern).

```python
from fastapi import FastAPI, WebSocket
import torch

app = FastAPI()
model = load_model()

@app.websocket("/ws/inference")
async def websocket_inference(websocket: WebSocket):
    await websocket.accept()
    while True:
        audio_bytes = await websocket.receive_bytes()
        audio = decode_audio(audio_bytes)
        with torch.inference_mode():
            output = model.stream_step(audio)
        await websocket.send_bytes(encode_audio(output))
```

## Rust / Candle (Moshi Backend Pattern)

From `moshi/rust/moshi-backend/`:

- **Framework**: Candle (Rust ML framework by HuggingFace)
- **Transport**: WebSocket for real-time audio
- **Advantages**: No GIL, minimal memory overhead, compile-time safety
- **Use case**: Ultra-low latency streaming inference

## Deployment Patterns

### Single Model

```yaml
# docker-compose.yml
services:
  model:
    image: vllm/vllm-openai:latest
    command: --model kyutai/moshi-7b --tensor-parallel-size 1
    deploy:
      resources:
        reservations:
          devices:
            - capabilities: [gpu]
              count: 1
    ports:
      - "8000:8000"
```

### Multi-Model (Unmute Pattern)

```yaml
services:
  gateway:
    image: nginx:alpine
    ports: ["80:80"]

  moshi:
    image: ghcr.io/kyutai-labs/moshi-server  # or build from https://github.com/kyutai-labs/moshi
    deploy:
      resources:
        reservations:
          devices: [{capabilities: [gpu], count: 1}]

  tts:
    image: ghcr.io/kyutai-labs/pocket-tts  # or build from source
    # CPU-only, no GPU needed

  encoder:
    image: ghcr.io/kyutai-labs/mimi-encoder  # or build from source
    deploy:
      resources:
        reservations:
          devices: [{capabilities: [gpu], count: 1}]
```

## Health Checks

```python
@app.get("/health")
async def health():
    return {
        "status": "healthy",
        "model_loaded": model is not None,
        "cuda_available": torch.cuda.is_available(),
        "gpu_memory_used_gb": torch.cuda.memory_allocated() / 1e9,
    }

@app.get("/health/ready")
async def readiness():
    # Test inference with dummy input
    with torch.inference_mode():
        model(dummy_input)
    return {"status": "ready"}
```

## Performance Tuning Checklist

- [ ] Enable torch.compile / CUDA graphs for static shapes
- [ ] Set optimal batch size (profile with increasing sizes)
- [ ] Enable Flash Attention (automatic in most frameworks)
- [ ] Configure KV cache size based on expected sequence lengths
- [ ] Set num_workers for data preprocessing
- [ ] Monitor GPU utilization (target > 80%)
- [ ] Set appropriate timeout and max queue length
- [ ] Enable request logging for debugging (disable in prod for perf)
