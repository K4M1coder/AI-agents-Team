---
name: ai-integration
description: "**WORKFLOW SKILL** — AI system integration: API design for ML, WebSocket streaming, microservice patterns, SDK design, embedding in apps, RAG pipelines, and model-family routing in application pipelines. USE FOR: designing ML APIs, implementing streaming inference, building SDKs, creating RAG systems, composing multi-model pipelines, and selecting the right open-weight family for an integration surface. USE WHEN: integrating a model into an application, designing an ML API, building streaming endpoints, or choosing model families for a product workflow."
argument-hint: "Describe the integration task: API design, streaming, SDK, RAG, or multi-model pipeline"
---

# AI Integration

Design and build integration layers that connect ML models to applications and users.

## When to Use

- Designing REST/WebSocket APIs for model serving
- Implementing streaming inference endpoints
- Building client SDKs (Python, JavaScript, Rust)
- Creating RAG (Retrieval-Augmented Generation) pipelines
- Composing multi-model pipelines
- Integrating ML into existing applications
- Choosing model families for APIs, assistants, RAG stacks, and multimodal workflows

## Core Concepts

| Concept | Description |
| --------- | ------------- |
| **Streaming API** | Real-time token/audio delivery via WebSocket or SSE |
| **Multi-Model Pipeline** | Chain multiple models (e.g., ASR → LLM → TTS) |
| **RAG** | Retrieve context from knowledge base before generation |
| **SDK** | Client library abstracting API complexity |
| **Rate Limiting** | Prevent abuse and ensure fair resource allocation |
| **Circuit Breaker** | Fail fast when downstream service is unhealthy |

## Open-Weight Model Routing Reference

Use `../_shared/references/llm-landscape.md` before fixing model choices in APIs or multi-model pipelines.

- Use `../_shared/references/models/` for code, reasoning, multimodal, translation, and OCR tradeoffs by family.
- Use `../_shared/references/models/edge-small.md` when the integration target includes offline, mobile, or low-memory clients.

## Procedure

### Phase 1: API Design

Define the interface:

```yaml
# OpenAPI spec pattern for ML inference
paths:
  /v1/inference:
    post:
      summary: Run model inference
      requestBody:
        content:
          application/json:
            schema:
              type: object
              properties:
                input: {type: string}
                parameters:
                  type: object
                  properties:
                    temperature: {type: number, default: 0.7}
                    max_tokens: {type: integer, default: 256}
      responses:
        200:
          content:
            application/json:
              schema:
                type: object
                properties:
                  output: {type: string}
                  usage: {type: object}

  /v1/stream:
    websocket:
      summary: Streaming inference
      messages:
        - direction: client
          payload: {type: binary}  # audio frames
        - direction: server
          payload: {type: binary}  # audio frames
```

### Phase 2: Streaming Implementation

**WebSocket Pattern (Reference: Kyutai Moshi/Unmute):**
```python
@app.websocket("/v1/stream")
async def stream_inference(ws: WebSocket):
    await ws.accept()
    session = create_session(model)

    try:
        while True:
            data = await ws.receive_bytes()
            frames = decode_frames(data)
            output = session.process(frames)
            if output is not None:
                await ws.send_bytes(encode_frames(output))
    except WebSocketDisconnect:
        session.cleanup()
```

**SSE Pattern (Text streaming):**
```python
@app.post("/v1/generate/stream")
async def stream_generate(request: GenerateRequest):
    async def event_stream():
        async for token in model.generate_stream(request.input):
            yield f"data: {json.dumps({'token': token})}\n\n"
        yield "data: [DONE]\n\n"
    return StreamingResponse(event_stream(), media_type="text/event-stream")
```

### Phase 3: SDK Design

```python
# Custom wrapper around Moshi's WebSocket API (self-hosted server)
# Install: pip install moshi websockets sounddevice numpy
import asyncio
import websockets
import json

class MoshiWebSocketClient:
    """Thin wrapper around the Moshi WebSocket server."""

    def __init__(self, base_url: str = "ws://localhost:8998"):
        self.base_url = base_url

    async def stream_audio(self, input_audio: bytes):
        """Full-duplex audio streaming with Moshi."""
        async with websockets.connect(f"{self.base_url}/api/chat") as ws:
            await ws.send(input_audio)
            async for message in ws:
                yield message  # raw audio bytes from Moshi

client = MoshiWebSocketClient(base_url="ws://your-moshi-server:8998")

# Streaming audio session
async def run():
    async for output_audio in client.stream_audio(input_audio):
        play(output_audio)
```

### Phase 4: RAG Pipeline

```text
ser Query
    ↓
Embed Query (embedding model)
    ↓
Vector Search (Qdrant / Weaviate / Pinecone)
    ↓
Rerank Results (cross-encoder)
    ↓
Build Prompt (query + top-k context)
    ↓
Generate Response (LLM)
    ↓
Return with Citations
```

**Key Parameters:**
- Chunk size: 256-512 tokens (with overlap 50-100)
- Top-k retrieval: 5-20 candidates
- Reranking: Cross-encoder on top-k, keep top 3-5
- Context window: Fit retrieved chunks within model's context

### Phase 5: Multi-Model Pipeline

**Reference Pattern (Kyutai/Unmute):**
```yaml
pipeline:
  - name: audio_encoder
    model: mimi
    input: raw_audio
    output: audio_tokens

  - name: language_model
    model: moshi-7b
    input: audio_tokens + text_tokens
    output: response_tokens

  - name: audio_decoder
    model: mimi
    input: response_tokens
    output: raw_audio
```

## Error Handling

| Error | HTTP Status | Client Action |
| ------- | ------------ | --------------- |
| Invalid input format | 400 | Fix request |
| Authentication failed | 401 | Check API key |
| Rate limit exceeded | 429 | Retry with backoff |
| Model not loaded | 503 | Retry later |
| Inference timeout | 504 | Retry or use smaller model |
| Internal error | 500 | Report bug |

## Output Format

- **API Specification**: OpenAPI/AsyncAPI schema
- **Integration Guide**: Step-by-step with code samples
- **SDK Design**: API surface, authentication, error handling
- **Architecture Diagram**: Component diagram with data flows
