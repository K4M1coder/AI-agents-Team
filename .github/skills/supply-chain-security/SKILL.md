---
name: supply-chain-security
description: "**WORKFLOW SKILL** — Secure the software supply chain from source to deployment. USE FOR: container image signing (Cosign/Sigstore), SLSA provenance generation, SBOM creation (Syft/Trivy), dependency scanning (Dependabot/Renovate/Grype), artifact attestation, OCI registry policies, admission controllers (Kyverno/OPA), reproducible builds, pinned dependencies, artifact integrity verification. USE WHEN: signing container images, generating SBOMs, configuring dependency updates, enforcing supply chain policies."
argument-hint: "Describe the supply chain task (e.g., 'Cosign image signing in GitHub Actions CI')"
---

# Supply Chain Security

Secure the software supply chain from source code to deployed artifacts.

## When to Use

- Signing container images for verification
- Generating SBOM (Software Bill of Materials)
- Setting up automated dependency updates
- Enforcing admission policies in Kubernetes
- Meeting SLSA compliance levels
- Auditing supply chain integrity

## SLSA Framework Levels

| Level | Requirement | Example |
| ------- | ------------ | --------- |
| SLSA 1 | Build process documented | CI pipeline exists |
| SLSA 2 | Version-controlled build, signed provenance | GitHub Actions + attestation |
| SLSA 3 | Hardened build platform, non-falsifiable provenance | Isolated builders |
| SLSA 4 | Two-party review, hermetic build | Full reproducibility |

## Procedure

### 1. Sign Container Images

See [Cosign/SLSA reference](./references/cosign-slsa.md).

```bash
# Keyless signing with Sigstore (recommended)
cosign sign --yes registry.example.com/app:v1.0.0

# Key-pair signing
cosign generate-key-pair
cosign sign --key cosign.key registry.example.com/app:v1.0.0

# Verify signature
cosign verify --certificate-identity=user@example.com \
  --certificate-oidc-issuer=https://token.actions.githubusercontent.com \
  registry.example.com/app:v1.0.0
```

### 2. Generate SBOM

```bash
# Syft — generate SBOM from image
syft registry.example.com/app:v1.0.0 -o spdx-json > sbom.spdx.json

# Trivy — SBOM generation
trivy image --format spdx-json -o sbom.json registry.example.com/app:v1.0.0

# Attach SBOM to image (OCI artifact)
cosign attach sbom --sbom sbom.spdx.json registry.example.com/app:v1.0.0

# Scan SBOM for vulnerabilities
grype sbom:./sbom.spdx.json
```

### 3. Configure Dependency Updates

```yaml
# Dependabot (.github/dependabot.yml)
version: 2
updates:
  - package-ecosystem: pip
    directory: "/"
    schedule:
      interval: weekly
    reviewers:
      - "team/security"
    labels:
      - "dependencies"
    open-pull-requests-limit: 10

  - package-ecosystem: docker
    directory: "/"
    schedule:
      interval: weekly

  - package-ecosystem: github-actions
    directory: "/"
    schedule:
      interval: weekly
```

### 4. Enforce Admission Policies

See [dependency hardening reference](./references/dependency-hardening.md).

```yaml
# Kyverno — require signed images
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: verify-image-signature
spec:
  validationFailureAction: Enforce
  rules:
    - name: verify-cosign-signature
      match:
        any:
          - resources:
              kinds: ["Pod"]
      verifyImages:
        - imageReferences:
            - "registry.example.com/*"
          attestors:
            - entries:
                - keyless:
                    issuer: "https://token.actions.githubusercontent.com"
                    subject: "https://github.com/org/repo/*"
```

### 5. Pin Dependencies

**Language-specific pinning:**
| Language | Lock File | Pin Tool |
| ---------- | ----------- | ---------- |
| Python | `requirements.txt` (hashed) | `pip-compile --generate-hashes` |
| Node.js | `package-lock.json` | `npm ci` (uses lock) |
| Go | `go.sum` | Built-in |
| Rust | `Cargo.lock` | Built-in |
| Docker | Digest pinning | `image@sha256:...` |
| GitHub Actions | SHA pinning | `uses: actions/checkout@abc123` |

## Supply Chain Checklist

- [ ] All container images signed (Cosign)
- [ ] SBOM generated and attached per release
- [ ] Dependencies pinned with lock files
- [ ] Dependabot/Renovate configured
- [ ] GitHub Actions pinned to commit SHAs
- [ ] Base images pinned to digests (not tags)
- [ ] Admission controller enforces image signatures
- [ ] Build provenance generated (SLSA)
- [ ] Private registry with vulnerability scanning
- [ ] Secret scanning enabled on repository

## Agent Integration

- **`executant-security-ops`**: Supply chain risk assessment and policy review
- **`executant-ci-cd-ops`**: Integrate signing, SBOM, and scanning into pipelines
- **`docker-containerization`** skill: Image build and scanning
- **`kubernetes-orchestration`** skill: Kyverno/OPA admission policies
