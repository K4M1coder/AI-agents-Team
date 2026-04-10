# Secrets — Encrypted Secret Management

## Overview

All secrets are encrypted at rest using **SOPS** with **age** as the encryption backend. Plaintext secrets must never be committed. The repository baseline validator enforces allowed file extensions.

## Allowed File Types

| Extension | Format | Usage |
|-----------|--------|-------|
| `*.enc.yaml` | SOPS-encrypted YAML | Service credentials, API keys |
| `*.enc.yml` | SOPS-encrypted YAML | Alternate extension |
| `*.enc.json` | SOPS-encrypted JSON | Structured config secrets |
| `*.age` | Raw age-encrypted | Certificates, private keys |

## SOPS + age Workflow

### Initial Setup

```bash
# Install age
# macOS: brew install age
# Linux: apt install age / dnf install age

# Generate a key pair
age-keygen -o ~/.config/sops/age/keys.txt

# Share your PUBLIC key with the team (add to .age-recipients.example.txt)
cat ~/.config/sops/age/keys.txt | grep "public key:"
```

### Encrypting a Secret

```bash
# Encrypt a YAML file
sops --encrypt --age $(cat .age-recipients.example.txt | grep -v '^#' | tr '\n' ',') \
  secrets/plaintext.yaml > secrets/plaintext.enc.yaml

# Or use the .sops.yaml config (preferred — auto-selects recipients)
sops --encrypt secrets/plaintext.yaml > secrets/plaintext.enc.yaml
```

### Decrypting a Secret

```bash
# Decrypt to stdout
sops --decrypt secrets/my-secret.enc.yaml

# Decrypt and edit in-place (opens $EDITOR)
sops secrets/my-secret.enc.yaml

# Decrypt to file
sops --decrypt secrets/my-secret.enc.yaml > /tmp/my-secret.yaml
```

### Rotating Keys

```bash
# Update .sops.yaml with new recipients, then rotate:
sops updatekeys secrets/my-secret.enc.yaml
```

## Key Management

- **Private keys**: Stored locally at `~/.config/sops/age/keys.txt` — never committed
- **Public keys**: Listed in `.age-recipients.example.txt` in this directory
- **SOPS config**: `.sops.yaml` at the repository root defines creation rules and age recipients
- **CI/CD**: The `SOPS_AGE_KEY` environment variable provides the decryption key in pipelines

## .gitignore Rules

The `secrets/.gitignore` ensures only encrypted files and metadata are tracked:
- `*.yaml` / `*.yml` / `*.json` (plaintext) — **ignored**
- `*.enc.yaml` / `*.enc.yml` / `*.enc.json` / `*.age` — **tracked**
- `README.md`, `.gitignore`, `.age-recipients.example.txt` — **tracked**

## Conventions

- Never commit plaintext secrets
- Use `.enc.` infix for all SOPS-encrypted files
- Rotate keys when team members leave
- See [secrets baseline policy](../policies/secrets-baseline.md)
