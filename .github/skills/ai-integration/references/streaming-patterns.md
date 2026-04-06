# Streaming Patterns for AI Integration

Patterns for real-time ML inference with low-latency streaming.

## Streaming Architecture Patterns

### Pattern 1: Audio Bidirectional (Moshi/Unmute)

```schema
                      ┌──────────────────────────────────────┐
                      │            Server                    │
 Client               │                                      │
 ┌──────┐  WebSocket  │  ┌────────┐  ┌─────┐  ┌────────┐     │
 │ Mic  │────────────▶│  │ Mimi   │──│Moshi│──│ Mimi   │    │
 │      │             │  │Encoder │  │ LM  │  │Decoder │     │
 │ Spkr │◀────────────│  └────────┘  └─────┘  └────────┘    │
 └──────┘             │       ↕                              │
                      │  KV Cache (per session)              │
                      └──────────────────────────────────────┘
```

**Key characteristics:**

- Bidirectional WebSocket (full-duplex)
- Frame rate: 12.5 Hz (80ms per Mimi frame)
- Per-session KV cache
- Real-time constraint: output must be generated before next input frame

### Pattern 2: Text Streaming (SSE)

```text schema
Client                          Server
  │                               │
  │── POST /v1/generate ─────────▶│
  │                               │── Generate token 1
  │◀── data: {"token":"Hello"} ──│
  │                               │── Generate token 2
  │◀── data: {"token":" world"} ─│
  │                               │── ...
  │◀── data: [DONE] ─────────────│
  │                               │
```

**Key characteristics:**

- Unidirectional (server → client)
- HTTP SSE (works through proxies/CDNs)
- Token-by-token delivery
- Backpressure handled by TCP flow control

### Pattern 3: Chunked Audio Processing

For non-real-time audio (batch with progress):

```text schema
Client                          Server
  │                               │
  │── Upload audio chunk 1 ──────▶│── Process
  │◀── Progress: 25% ────────────│
  │── Upload audio chunk 2 ──────▶│── Process
  │◀── Progress: 50% ────────────│
  │── Upload audio chunk 3 ──────▶│── Process
  │◀── Progress: 75% ────────────│
  │── Upload audio chunk 4 ──────▶│── Process
  │◀── Result ────────────────────│
```

## Implementation Details

### Ring Buffer for Audio Input

```python
class RingBuffer:
    def __init__(self, capacity: int, dtype=np.float32):
        self.buffer = np.zeros(capacity, dtype=dtype)
        self.capacity = capacity
        self.write_pos = 0
        self.read_pos = 0
        self.available = 0

    def write(self, data: np.ndarray) -> int:
        n = len(data)
        if n > self.capacity - self.available:
            n = self.capacity - self.available  # drop overflow

        end = self.write_pos + n
        if end <= self.capacity:
            self.buffer[self.write_pos:end] = data[:n]
        else:
            first = self.capacity - self.write_pos
            self.buffer[self.write_pos:] = data[:first]
            self.buffer[:n - first] = data[first:n]

        self.write_pos = (self.write_pos + n) % self.capacity
        self.available += n
        return n

    def read(self, n: int) -> np.ndarray:
        n = min(n, self.available)
        end = self.read_pos + n
        if end <= self.capacity:
            data = self.buffer[self.read_pos:end].copy()
        else:
            first = self.capacity - self.read_pos
            data = np.concatenate([
                self.buffer[self.read_pos:],
                self.buffer[:n - first],
            ])
        self.read_pos = (self.read_pos + n) % self.capacity
        self.available -= n
        return data

    def has_frame(self, frame_size: int) -> bool:
        return self.available >= frame_size
```

### Session Manager

```python
import asyncio
from typing import Dict

class SessionManager:
    def __init__(self, model, max_sessions: int = 100):
        self.model = model
        self.sessions: Dict[str, StreamSession] = {}
        self.max_sessions = max_sessions
        self._lock = asyncio.Lock()

    async def create_session(self, session_id: str) -> StreamSession:
        async with self._lock:
            if len(self.sessions) >= self.max_sessions:
                # Evict oldest session
                oldest = min(self.sessions.values(), key=lambda s: s.last_active)
                await self.close_session(oldest.session_id)

            session = StreamSession(self.model, session_id)
            self.sessions[session_id] = session
            return session

    async def close_session(self, session_id: str):
        async with self._lock:
            if session_id in self.sessions:
                self.sessions[session_id].cleanup()
                del self.sessions[session_id]

    async def get_session(self, session_id: str) -> Optional[StreamSession]:
        session = self.sessions.get(session_id)
        if session:
            session.last_active = time.time()
        return session
```

### Backpressure Handling

```python
@app.websocket("/v1/stream")
async def stream(ws: WebSocket):
    await ws.accept()
    session = await session_manager.create_session(str(uuid4()))

    try:
        while True:
            # Receive with timeout (detect stale connections)
            try:
                data = await asyncio.wait_for(ws.receive_bytes(), timeout=30.0)
            except asyncio.TimeoutError:
                await ws.send_json({"type": "ping"})
                continue

            output = session.process_frame(data)
            if output is not None:
                try:
                    await asyncio.wait_for(ws.send_bytes(output), timeout=5.0)
                except asyncio.TimeoutError:
                    # Client can't keep up — drop frame
                    session.metrics.dropped_frames += 1
    except WebSocketDisconnect:
        pass
    finally:
        await session_manager.close_session(session.session_id)
```

## Latency Optimization

| Technique | Latency Reduction | Where |
| ----------- | ------------------ | ------- |
| CUDA graphs | 2-5ms per step | GPU compute |
| Compiled kernels | 1-3ms per step | GPU compute |
| Ring buffer | Avoid copies | CPU ↔ GPU |
| Pre-allocated tensors | Avoid allocation | Memory |
| Connection pooling | Avoid reconnect | Network |
| Frame pipelining | Overlap I/O + compute | End-to-end |
| WebSocket binary | Avoid encoding | Network |

## Monitoring

```python
# Key metrics for streaming inference
STREAM_FRAME_LATENCY = Histogram(
    "stream_frame_latency_seconds",
    "Latency per streaming frame",
    buckets=[0.005, 0.01, 0.02, 0.04, 0.08, 0.16],
)

STREAM_DROPPED_FRAMES = Counter(
    "stream_dropped_frames_total",
    "Frames dropped due to backpressure",
)

STREAM_ACTIVE_SESSIONS = Gauge(
    "stream_active_sessions",
    "Number of active streaming sessions",
)
```text
