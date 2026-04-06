---
name: docker-containerization
description: "**WORKFLOW SKILL** — Build, secure, and optimize Docker containers. USE FOR: Dockerfile authoring, multi-stage builds, Docker Compose service definitions, image hardening (non-root, distroless, scratch), layer optimization, BuildKit features, health checks, container networking, registry management, Trivy/Grype scanning, .dockerignore, build args vs env vars, volume patterns. USE WHEN: containerizing applications, writing Dockerfiles, creating docker-compose.yml, scanning images for vulnerabilities."
argument-hint: "Describe the containerization task (e.g., 'multi-stage Python API image with non-root user')"
---

# Docker Containerization

Build, secure, and optimize Docker containers following production best practices.

## When to Use

- Writing or reviewing Dockerfiles
- Creating docker-compose.yml service stacks
- Optimizing image size and build speed
- Hardening container images for production
- Scanning images for vulnerabilities

## Procedure

### 1. Assess the Application

Determine:
- **Runtime**: Python, Node.js, Go, Rust, Java, .NET, static files
- **Base image strategy**: Official slim → distroless → scratch
- **Build complexity**: Single-stage vs multi-stage
- **Dependencies**: System packages, build tools, runtime-only libs

### 2. Write the Dockerfile

See [Dockerfile patterns reference](./references/dockerfile-patterns.md) for language-specific templates.

**Core rules:**
- Use specific image tags, never `latest`: `python:3.12-slim-bookworm`
- Multi-stage builds: separate build and runtime stages
- Non-root user: Always run as non-root in production
- `.dockerignore`: Exclude `.git/`, `node_modules/`, `__pycache__/`, `.env`, etc.
- Layer ordering: Least-changing layers first (OS deps → app deps → code)
- `COPY` over `ADD` (unless extracting tar or fetching URL)
- One `RUN` per logical step (combine with `&&` to reduce layers)
- `HEALTHCHECK`: Define for every service container

### 3. Optimize Build Performance

```dockerfile
# Leverage BuildKit cache mounts
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --no-compile -r requirements.txt

# Leverage BuildKit bind mounts (no COPY needed for build-only files)
RUN --mount=type=bind,source=package.json,target=package.json \
    --mount=type=bind,source=package-lock.json,target=package-lock.json \
    --mount=type=cache,target=/root/.npm \
    npm ci
```

### 4. Harden the Image

**Image hardening checklist:**
- [ ] Non-root USER directive
- [ ] Read-only root filesystem (`--read-only` at runtime)
- [ ] No shell in production (distroless/scratch)
- [ ] No secrets in image layers (use BuildKit secrets)
- [ ] Minimal packages (no curl/wget/vi in prod images)
- [ ] HEALTHCHECK defined
- [ ] Security scanning passed (Trivy/Grype)

### 5. Compose Services

```yaml
# docker-compose.yml best practices
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
      target: runtime           # Multi-stage target
    image: registry.example.com/app:${TAG:-latest}
    restart: unless-stopped
    read_only: true
    security_opt:
      - no-new-privileges:true
    healthcheck:
      test: ["CMD", "/healthcheck"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 10s
    deploy:
      resources:
        limits:
          cpus: "2.0"
          memory: 512M
    logging:
      driver: json-file
      options:
        max-size: "10m"
        max-file: "3"
```

### 6. Scan for Vulnerabilities

See [security scanning reference](./references/security-scanning.md).

```bash
# Trivy — comprehensive scanner
trivy image --severity HIGH,CRITICAL myimage:latest

# Grype — alternative scanner
grype myimage:latest

# Scan Dockerfile for misconfigurations
trivy config Dockerfile

# Docker Scout (Docker Desktop built-in)
docker scout cves myimage:latest
```

## Base Image Decision Tree

```text
Is the app statically compiled (Go, Rust)?
├─ Yes → scratch or distroless/static
└─ No
   ├─ Does it need libc/libssl?
   │  ├─ Yes → distroless/base or *-slim
   │  └─ No → scratch
   └─ Does it need a package manager at runtime?
      ├─ Yes (debugging) → *-slim (dev only)
      └─ No → distroless/<runtime>
```

| Runtime | Production Base | Dev/Debug Base |
| --------- | ---------------- | ---------------- |
| Python | `python:3.12-slim-bookworm` | `python:3.12-bookworm` |
| Node.js | `node:22-slim` or distroless | `node:22-bookworm` |
| Go | `scratch` or `distroless/static` | `golang:1.22` (build stage) |
| Rust | `scratch` or `distroless/cc` | `rust:1.78` (build stage) |
| Java | `eclipse-temurin:21-jre-jammy` | `eclipse-temurin:21-jdk` |
| .NET | `mcr.microsoft.com/dotnet/runtime:8.0` | `mcr.microsoft.com/dotnet/sdk:8.0` |

## Anti-Patterns

- Running as root
- Using `latest` tag
- Storing secrets in ENV or build layers
- `apt-get install` without `--no-install-recommends`
- Missing `.dockerignore`
- `COPY . .` before installing dependencies (cache invalidation)
- Not pinning package versions

## Agent Integration

- **`executant-security-ops`**: Review Dockerfile hardening and scan results
- **`executant-ci-cd-ops`**: Integrate build + scan + push into CI pipeline
- **`supply-chain-security`** skill: Sign images with Cosign, verify provenance
