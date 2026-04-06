# Cosign & SLSA Reference

## Cosign Installation

```bash
# Linux
curl -LO https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64
mv cosign-linux-amd64 /usr/local/bin/cosign && chmod +x /usr/local/bin/cosign

# macOS
brew install cosign

# Windows
choco install cosign
```

## Keyless Signing (Sigstore — Recommended)

Uses short-lived certificates from Fulcio + Rekor transparency log. No key management required.

```bash
# Sign (opens browser for OIDC auth)
cosign sign --yes registry.example.com/app:v1.0.0

# Verify with identity constraints
cosign verify \
  --certificate-identity=user@example.com \
  --certificate-oidc-issuer=https://accounts.google.com \
  registry.example.com/app:v1.0.0

# Verify in CI (GitHub Actions identity)
cosign verify \
  --certificate-identity-regexp="https://github.com/myorg/.*" \
  --certificate-oidc-issuer=https://token.actions.githubusercontent.com \
  registry.example.com/app:v1.0.0
```

## Key-Pair Signing (Air-Gapped)

```bash
# Generate key pair
cosign generate-key-pair
# Creates cosign.key (private) and cosign.pub (public)

# Sign with key
cosign sign --key cosign.key registry.example.com/app:v1.0.0

# Verify with public key
cosign verify --key cosign.pub registry.example.com/app:v1.0.0

# Sign with KMS-managed key
cosign sign --key hashivault://transit/keys/cosign registry.example.com/app:v1.0.0
cosign sign --key awskms:///arn:aws:kms:... registry.example.com/app:v1.0.0
cosign sign --key azurekms://vault/key/version registry.example.com/app:v1.0.0
```

## Attestations

```bash
# Create attestation (SLSA provenance)
cosign attest --yes \
  --predicate provenance.json \
  --type slsaprovenance \
  registry.example.com/app:v1.0.0

# Verify attestation
cosign verify-attestation \
  --certificate-identity-regexp="https://github.com/myorg/.*" \
  --certificate-oidc-issuer=https://token.actions.githubusercontent.com \
  --type slsaprovenance \
  registry.example.com/app:v1.0.0

# Attach SBOM
cosign attach sbom --sbom sbom.spdx.json registry.example.com/app:v1.0.0

# Sign the attached SBOM
cosign sign --yes --attachment sbom registry.example.com/app:v1.0.0
```

## GitHub Actions Integration

### Keyless Sign + Verify

```yaml
name: Build, Sign, and Push
on:
  push:
    tags: ['v*']

permissions:
  contents: read
  packages: write
  id-token: write  # Required for keyless signing

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: sigstore/cosign-installer@v3

      - uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push
        id: build
        uses: docker/build-push-action@v5
        with:
          push: true
          tags: ghcr.io/${{ github.repository }}:${{ github.ref_name }}

      - name: Sign image
        run: |
          cosign sign --yes \
            ghcr.io/${{ github.repository }}@${{ steps.build.outputs.digest }}

      - name: Generate SBOM
        uses: anchore/sbom-action@v0
        with:
          image: ghcr.io/${{ github.repository }}@${{ steps.build.outputs.digest }}
          format: spdx-json
          output-file: sbom.spdx.json

      - name: Attest SBOM
        run: |
          cosign attest --yes \
            --predicate sbom.spdx.json \
            --type spdxjson \
            ghcr.io/${{ github.repository }}@${{ steps.build.outputs.digest }}
```

### SLSA Provenance with slsa-github-generator

```yaml
name: SLSA Build
on:
  push:
    tags: ['v*']

jobs:
  build:
    outputs:
      digest: ${{ steps.build.outputs.digest }}
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build and push
        id: build
        uses: docker/build-push-action@v5
        with:
          push: true
          tags: ghcr.io/${{ github.repository }}:${{ github.ref_name }}

  provenance:
    needs: build
    permissions:
      actions: read
      id-token: write
      packages: write
    uses: slsa-framework/slsa-github-generator/.github/workflows/generator_container_slsa3.yml@v2.0.0
    with:
      image: ghcr.io/${{ github.repository }}
      digest: ${{ needs.build.outputs.digest }}
      registry-username: ${{ github.actor }}
    secrets:
      registry-password: ${{ secrets.GITHUB_TOKEN }}
```

## Rekor Transparency Log

```bash
# Search transparency log
rekor-cli search --email user@example.com

# Get log entry
rekor-cli get --uuid <UUID>

# Verify inclusion
cosign verify --certificate-identity=... --certificate-oidc-issuer=... \
  registry.example.com/app:v1.0.0

# The verification automatically checks Rekor
```text
