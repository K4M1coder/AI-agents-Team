# API Patterns for AI Integration

Design patterns for building robust ML APIs.

## RESTful ML API Pattern

### Standard Endpoints

```text
POST   /v1/models/{model_id}/infer        # Synchronous inference
POST   /v1/models/{model_id}/infer/stream  # Streaming inference (SSE)
WS     /v1/models/{model_id}/stream        # WebSocket bidirectional
GET    /v1/models                          # List available models
GET    /v1/models/{model_id}               # Model info
GET    /v1/health                          # Health check
GET    /v1/health/ready                    # Readiness (model loaded)
POST   /v1/models/{model_id}/embed         # Embedding generation
```

### Request/Response Schema

```json
// POST /v1/models/moshi-7b/infer
// Request
{
  "input": "Hello, how are you?",
  "parameters": {
    "temperature": 0.7,
    "top_p": 0.9,
    "max_tokens": 256
  },
  "metadata": {
    "request_id": "uuid-v4",
    "session_id": "session-123"
  }
}

// Response
{
  "output": "I'm doing well, thank you!",
  "usage": {
    "input_tokens": 5,
    "output_tokens": 7,
    "total_tokens": 12,
    "compute_ms": 143
  },
  "model": "moshi-7b",
  "request_id": "uuid-v4"
}
```

## WebSocket Streaming Pattern (Reference: Kyutai/Moshi)

Used in Moshi and Unmute for real-time audio.

### Protocol

```text
Client                                    Server
  │                                         │
  │──── CONNECT /v1/stream ────────────────▶│
  │◀─── Accept + session_id ───────────────│
  │                                         │
  │──── Audio Frame (binary) ──────────────▶│
  │◀─── Audio Frame (binary) ──────────────│
  │                                         │
  │──── Audio Frame (binary) ──────────────▶│
  │◀─── Audio Frame (binary) ──────────────│
  │     ...bidirectional streaming...        │
  │                                         │
  │──── Close ─────────────────────────────▶│
  │◀─── Clean up session + KV cache ───────│
```

### Frame Format (Binary)

```text
Byte 0:     Frame type (0x01 = audio, 0x02 = text, 0x03 = control)
Bytes 1-4:  Sequence number (uint32, big-endian)
Bytes 5-8:  Timestamp (uint32, big-endian, milliseconds)
Bytes 9-N:  Payload (audio samples or UTF-8 text)
```

### Session Management

```python
class StreamSession:
    def __init__(self, model, session_id: str):
        self.session_id = session_id
        self.model = model
        self.kv_cache = model.create_kv_cache()
        self.audio_buffer = RingBuffer(max_size=48000)  # 2 seconds at 24kHz
        self.created_at = time.time()

    def process_frame(self, audio_frame: bytes) -> Optional[bytes]:
        self.audio_buffer.write(audio_frame)
        if self.audio_buffer.has_full_frame():
            tokens = self.encoder.encode(self.audio_buffer.read_frame())
            output_tokens = self.model.step(tokens, self.kv_cache)
            return self.decoder.decode(output_tokens)
        return None

    def cleanup(self):
        del self.kv_cache
        torch.cuda.empty_cache()
```

## SSE (Server-Sent Events) Pattern

For text streaming:

```python
from fastapi import FastAPI
from fastapi.responses import StreamingResponse

@app.post("/v1/generate/stream")
async def stream_generate(request: GenerateRequest):
    async def event_generator():
        async for token in model.generate_stream(
            request.input,
            temperature=request.parameters.temperature,
            max_tokens=request.parameters.max_tokens,
        ):
            data = {"token": token, "finish_reason": None}
            yield f"data: {json.dumps(data)}\n\n"
        yield f"data: {json.dumps({'token': '', 'finish_reason': 'stop'})}\n\n"
        yield "data: [DONE]\n\n"

    return StreamingResponse(
        event_generator(),
        media_type="text/event-stream",
        headers={"Cache-Control": "no-cache", "X-Accel-Buffering": "no"},
    )
```

## Authentication & Rate Limiting

### API Key Authentication

```python
from fastapi import Depends, HTTPException, Security
from fastapi.security import APIKeyHeader

api_key_header = APIKeyHeader(name="Authorization", auto_error=False)

async def verify_api_key(api_key: str = Security(api_key_header)):
    if not api_key or not api_key.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid API key")
    token = api_key.replace("Bearer ", "")
    if not await validate_key(token):
        raise HTTPException(status_code=401, detail="Invalid API key")
    return token
```

### Rate Limiting

```python
from slowapi import Limiter
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_api_key_from_request)

@app.post("/v1/infer")
@limiter.limit("100/minute")  # per API key
async def infer(request: Request):
    ...
```

## Error Response Standard

```json
{
  "error": {
    "code": "rate_limit_exceeded",
    "message": "You have exceeded the rate limit of 100 requests/minute",
    "type": "rate_limit_error",
    "param": null,
    "retry_after": 30
  }
}
```

| Code | HTTP | Meaning |
| ------ | ------ | --------- |
| `invalid_request` | 400 | Bad input format |
| `authentication_error` | 401 | Invalid or missing API key |
| `rate_limit_exceeded` | 429 | Too many requests |
| `model_not_found` | 404 | Requested model doesn't exist |
| `model_overloaded` | 503 | Model at capacity |
| `internal_error` | 500 | Server error |
