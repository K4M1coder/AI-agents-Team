# Dockerfile Patterns Reference

## Python Multi-Stage

```dockerfile
# syntax=docker/dockerfile:1
FROM python:3.12-slim-bookworm AS builder

WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc libpq-dev \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --no-compile --prefix=/install -r requirements.txt

# ---
FROM python:3.12-slim-bookworm AS runtime

RUN groupadd --gid 1000 app && \
    useradd --uid 1000 --gid app --shell /bin/false --create-home app

COPY --from=builder /install /usr/local
WORKDIR /app
COPY --chown=app:app . .

USER app
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD ["python", "-c", "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')"]
CMD ["python", "-m", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

## Node.js Multi-Stage

```dockerfile
# syntax=docker/dockerfile:1
FROM node:22-slim AS builder

WORKDIR /app
COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm \
    npm ci --ignore-scripts
COPY . .
RUN npm run build

# ---
FROM node:22-slim AS runtime

RUN groupadd --gid 1000 app && \
    useradd --uid 1000 --gid app --shell /bin/false --create-home app

WORKDIR /app
COPY --from=builder --chown=app:app /app/dist ./dist
COPY --from=builder --chown=app:app /app/node_modules ./node_modules
COPY --from=builder --chown=app:app /app/package.json ./

USER app
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD ["node", "-e", "require('http').get('http://localhost:3000/health', r => r.statusCode === 200 ? process.exit(0) : process.exit(1))"]
CMD ["node", "dist/index.js"]
```

## Go Scratch

```dockerfile
# syntax=docker/dockerfile:1
FROM golang:1.22-bookworm AS builder

WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /app ./cmd/server

# ---
FROM scratch

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /app /app

USER 65534:65534
EXPOSE 8080
ENTRYPOINT ["/app"]
```

## Rust Scratch

```dockerfile
# syntax=docker/dockerfile:1
FROM rust:1.78-bookworm AS builder

WORKDIR /src
COPY Cargo.toml Cargo.lock ./
# Cache dependencies
RUN mkdir src && echo 'fn main(){}' > src/main.rs && cargo build --release && rm -rf src

COPY . .
RUN cargo build --release

# ---
FROM gcr.io/distroless/cc-debian12

COPY --from=builder /src/target/release/myapp /app
USER 65534:65534
EXPOSE 8080
ENTRYPOINT ["/app"]
```

## Nginx Static Files

```dockerfile
# syntax=docker/dockerfile:1
FROM node:22-slim AS builder

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN npm run build

# ---
FROM nginx:1.27-alpine AS runtime

# Remove default config
RUN rm /etc/nginx/conf.d/default.conf

COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/app.conf

# Run as non-root
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    touch /var/run/nginx.pid && \
    chown nginx:nginx /var/run/nginx.pid

USER nginx
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD ["wget", "--spider", "-q", "http://localhost:8080/"]
CMD ["nginx", "-g", "daemon off;"]
```

## .dockerignore Template

```text
.git
.gitignore
.github
.vscode
.env
.env.*
*.md
!README.md
docker-compose*.yml
Dockerfile*
__pycache__
*.pyc
.pytest_cache
.mypy_cache
node_modules
.next
dist
target
coverage
.terraform
*.tfstate*
```

## Build Arg vs ENV

| Feature | `ARG` | `ENV` |
| --------- | ------- | ------- |
| Available at | Build time only | Build + runtime |
| Layers | Not persisted in image | Persisted in image metadata |
| Override | `--build-arg` | `-e` or `--env` at run |
| Secrets | Use `--secret` instead | Never for secrets |

### Secret Mount Pattern (BuildKit)

```dockerfile
# Pass secrets without baking into layers
RUN --mount=type=secret,id=npmrc,target=/root/.npmrc \
    npm ci

# Build command:
# docker build --secret id=npmrc,src=.npmrc .
```text
