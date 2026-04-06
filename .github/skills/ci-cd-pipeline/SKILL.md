---
name: ci-cd-pipeline
description: "**WORKFLOW SKILL** — Design and implement CI/CD pipelines across platforms. USE FOR: GitHub Actions workflows, GitLab CI/CD pipelines, Jenkins pipelines (declarative/scripted), Dagger pipelines (code-based CI), multi-stage pipelines (lint → test → build → scan → deploy), matrix builds, caching strategies, artifact management, environment promotion (dev → staging → prod), branch protection rules, DORA metrics tracking, pipeline security (OIDC, least privilege). USE WHEN: creating CI/CD pipelines, optimizing build times, setting up deployment automation."
argument-hint: "Describe the pipeline (e.g., 'GitHub Actions for Python app with Docker build and ArgoCD deploy')"
---

# CI/CD Pipeline

Design and implement CI/CD pipelines with security gates and deployment automation.

## When to Use

- Creating new CI/CD pipelines from scratch
- Migrating between CI platforms
- Optimizing existing pipeline performance
- Adding security gates (scan, sign, verify)
- Setting up deployment automation (GitOps, blue-green, canary)

## Pipeline Stages

```text
┌──────┐  ┌──────┐  ┌───────┐  ┌──────┐  ┌────────┐  ┌────────┐
│ Lint │─▶│ Test │─▶│ Build │─▶│ Scan │─▶│  Sign  │─▶│ Deploy │
└──────┘  └──────┘  └───────┘  └──────┘  └────────┘  └────────┘
```

### Stage Details

| Stage | Purpose | Tools | Fail Action |
| ------- | --------- | ------- | ------------- |
| Lint | Code style, syntax | ruff, eslint, ansible-lint, terraform fmt | Block PR |
| Test | Correctness | pytest, jest, go test, Molecule | Block merge |
| Build | Artifact creation | Docker, npm, pip, cargo | Block |
| Scan | Vulnerabilities | Trivy, Grype, Checkov, tfsec | Block on CRITICAL |
| Sign | Integrity | Cosign, SLSA provenance | Block deploy |
| Deploy | Release | ArgoCD, Helm, Terraform apply | Rollback on failure |

## GitHub Actions Patterns

### Python Application

```yaml
name: CI/CD
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

permissions:
  contents: read
  packages: write
  id-token: write  # Cosign keyless signing

env:
  IMAGE: ghcr.io/${{ github.repository }}

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
      - run: pip install ruff
      - run: ruff check .
      - run: ruff format --check .

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
          cache: pip
      - run: pip install -e ".[test]"
      - run: pytest --cov --cov-report=xml
      - uses: actions/upload-artifact@v4
        with:
          name: coverage
          path: coverage.xml

  build:
    needs: [lint, test]
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    outputs:
      digest: ${{ steps.build.outputs.digest }}
    steps:
      - uses: actions/checkout@v4

      - uses: docker/setup-buildx-action@v3

      - uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push
        id: build
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: |
            ${{ env.IMAGE }}:${{ github.sha }}
            ${{ env.IMAGE }}:latest
          cache-from: type=gha
          cache-to: type=gha,mode=max

  scan:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ env.IMAGE }}:${{ github.sha }}
          severity: CRITICAL,HIGH
          exit-code: 1

  sign:
    needs: [build, scan]
    runs-on: ubuntu-latest
    steps:
      - uses: sigstore/cosign-installer@v3
      - run: cosign sign --yes ${{ env.IMAGE }}@${{ needs.build.outputs.digest }}

  deploy:
    needs: sign
    runs-on: ubuntu-latest
    environment: production
    steps:
      - uses: actions/checkout@v4
      - name: Update image tag in GitOps repo
        run: |
          # Update image tag in ArgoCD-managed manifests
          yq -i '.spec.template.spec.containers[0].image = "${{ env.IMAGE }}:${{ github.sha }}"' \
            k8s/overlays/prod/deployment-patch.yaml
          # Commit and push to GitOps repo
```

### Matrix Build (Multi-OS/Version)

```yaml
test:
  strategy:
    matrix:
      os: [ubuntu-latest, windows-latest]
      python-version: ["3.11", "3.12"]
    fail-fast: false
  runs-on: ${{ matrix.os }}
  steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-python@v5
      with:
        python-version: ${{ matrix.python-version }}
    - run: pip install -e ".[test]"
    - run: pytest
```

## GitLab CI Pattern

```yaml
stages:
  - lint
  - test
  - build
  - scan
  - deploy

variables:
  IMAGE: $CI_REGISTRY_IMAGE

lint:
  stage: lint
  image: python:3.12-slim
  script:
    - pip install ruff
    - ruff check .

test:
  stage: test
  image: python:3.12
  script:
    - pip install -e ".[test]"
    - pytest --cov
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage.xml

build:
  stage: build
  image: docker:24
  services:
    - docker:24-dind
  script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - docker build -t $IMAGE:$CI_COMMIT_SHA .
    - docker push $IMAGE:$CI_COMMIT_SHA
  only:
    - main

scan:
  stage: scan
  image:
    name: aquasec/trivy
    entrypoint: [""]
  script:
    - trivy image --exit-code 1 --severity CRITICAL $IMAGE:$CI_COMMIT_SHA
  only:
    - main

deploy-prod:
  stage: deploy
  environment:
    name: production
  script:
    - echo "Deploy via ArgoCD sync"
  when: manual
  only:
    - main
```

## Security Gates

| Gate | Tool | Threshold | Stage |
| ------ | ------ | ----------- | ------- |
| Linting | ruff/eslint/ansible-lint | Zero errors | Lint |
| Unit tests | pytest/jest | 80%+ coverage | Test |
| SAST | Semgrep/CodeQL | No HIGH+ | Test |
| Image scan | Trivy/Grype | No CRITICAL unfixed | Post-build |
| Config scan | Checkov/tfsec | No HIGH+ | Post-build |
| Secret scan | Trivy/gitleaks | Zero secrets | Pre-commit |
| License scan | Trivy/Fossa | No copyleft in proprietary | Build |
| Signature | Cosign | Valid signature | Pre-deploy |

## DORA Metrics

| Metric | Elite | High | Medium | Low |
| -------- | ------- | ------ | -------- | ----- |
| Deploy Frequency | On-demand (multiple/day) | Weekly-monthly | Monthly-6mo | >6 months |
| Lead Time | <1 hour | 1 day-1 week | 1-6 months | >6 months |
| Change Failure Rate | <5% | 5-10% | 10-15% | >15% |
| MTTR | <1 hour | <1 day | 1 day-1 week | >1 week |

## Agent Integration

- **`executant-ci-cd-ops`** agent: Pipeline architecture and optimization
- **`executant-security-ops`**: Security gate configuration and policy
- **`supply-chain-security`** skill: Image signing, SBOM, SLSA in pipeline
- **`docker-containerization`** skill: Build stage optimization
