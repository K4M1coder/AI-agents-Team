# ML Model Audio Container Patterns

> Reference: These Docker patterns are based on Kyutai open-source ML projects (Moshi, Pocket-TTS, Unmute, Mimi). Use as integrator/operator reference for similar audio AI deployment workloads.

## Pattern 1: GPU ML Server (Moshi-style)

Multi-stage build for a PyTorch model server with GPU and WebSocket streaming.

```dockerfile
# syntax=docker/dockerfile:1
FROM nvidia/cuda:12.4.1-devel-ubuntu22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-dev python3-pip python3-venv git && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /build
COPY pyproject.toml requirements.txt ./
RUN python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --no-cache-dir -U pip setuptools wheel && \
    /opt/venv/bin/pip install --no-cache-dir -r requirements.txt

COPY . .
RUN /opt/venv/bin/pip install --no-cache-dir .

# --- Runtime ---
FROM nvidia/cuda:12.4.1-runtime-ubuntu22.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 libsndfile1 ffmpeg && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

RUN useradd -m -s /bin/bash appuser
USER appuser
WORKDIR /home/appuser

EXPOSE 8998
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD python3 -c "import urllib.request; urllib.request.urlopen('http://localhost:8998/health')"

CMD ["python3", "-m", "moshi.server", "--host", "0.0.0.0", "--port", "8998"]
```

**Key decisions**:

- `libsndfile1` + `ffmpeg` — Required for audio I/O (soundfile, torchaudio)
- Runtime image uses `-runtime` not `-devel` (saves ~2.5 GB)
- Non-root user for security

## Pattern 2: CPU-Only TTS (Pocket-TTS-style)

Lightweight image for CPU inference — no CUDA dependency.

```dockerfile
FROM python:3.12-slim AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential libsndfile1-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /build
COPY pyproject.toml requirements.txt ./
RUN pip install --no-cache-dir --prefix=/install \
    torch --index-url https://download.pytorch.org/whl/cpu && \
    pip install --no-cache-dir --prefix=/install -r requirements.txt

COPY . .
RUN pip install --no-cache-dir --prefix=/install .

FROM python:3.12-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    libsndfile1 ffmpeg && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /install /usr/local

RUN useradd -m -s /bin/bash appuser
USER appuser
WORKDIR /home/appuser

EXPOSE 8000
CMD ["python3", "-m", "pocket_tts.serve", "--host", "0.0.0.0"]
```

**Key decisions**:

- CPU-only PyTorch (`--index-url .../cpu`) — image ~1 GB vs ~5 GB with CUDA
- No NVIDIA base image needed
- Ideal for edge deployment or cost-sensitive serving

## Pattern 3: Multi-Service Orchestrator (Unmute-style)

Docker Compose for a multi-model orchestrator with frontend.

```yaml
services:
  # API backend (orchestrator)
  api:
    build:
      context: .
      dockerfile: Dockerfile
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
    ports:
      - "8000:8000"
    environment:
      - MOSHI_URL=http://moshi:8998
      - TTS_URL=http://tts:8001
      - NVIDIA_VISIBLE_DEVICES=all
    volumes:
      - model-cache:/root/.cache/huggingface
      - ./voices.yaml:/app/voices.yaml:ro
    shm_size: "4g"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 5s
      retries: 3

  # TTS service (can be CPU-only)
  tts:
    build:
      context: ./pocket-tts
    ports:
      - "8001:8000"
    environment:
      - DEVICE=cpu
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 5s
      retries: 3

  # Frontend
  frontend:
    build:
      context: ./frontend
    ports:
      - "3000:80"
    depends_on:
      api:
        condition: service_healthy

  # Reverse proxy
  nginx:
    image: nginx:1.27-alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - api
      - frontend

volumes:
  model-cache:
```

## Pattern 4: Rust ML Server (Moshi-RS-style)

Multi-stage Rust build with CUDA runtime.

```dockerfile
FROM rust:1.82-bookworm AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    pkg-config libssl-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /build
COPY Cargo.toml Cargo.lock ./
COPY src/ src/

# Build release binary
RUN cargo build --release

# --- Runtime ---
FROM nvidia/cuda:12.4.1-runtime-ubuntu22.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates libssl3 && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /build/target/release/moshi-server /usr/local/bin/

RUN useradd -m -s /bin/bash appuser
USER appuser

EXPOSE 8998
CMD ["moshi-server", "--host", "0.0.0.0", "--port", "8998"]
```

**Key decisions**:

- Rust build stage doesn't need CUDA (model ops via candle at runtime)
- Final binary is ~20-50 MB vs ~5 GB Python image
- Ideal for production deployment

## Audio-Specific Docker Considerations

| Requirement | Solution |
| ------------ | ---------- |
| Audio codec libraries | `apt-get install libsndfile1 ffmpeg` |
| ALSA/PulseAudio (live mic) | Mount `/dev/snd` + `--device /dev/snd` |
| Large model downloads | Use volume mount, not bake into image |
| Shared memory (PyTorch IPC) | `shm_size: "8g"` or `ipc: host` |
| WebSocket timeouts | Nginx: `proxy_read_timeout 3600s` |
| Streaming audio latency | Use `--network host` for dev, proper ingress for prod |
