# SOPS Configuration Reference

## Installation

```bash
# Linux
curl -LO https://github.com/getsops/sops/releases/download/v3.9.0/sops-v3.9.0.linux.amd64
mv sops-v3.9.0.linux.amd64 /usr/local/bin/sops && chmod +x /usr/local/bin/sops

# macOS
brew install sops

# Windows
choco install sops
```

## Key Management

### age (Recommended)

```bash
# Generate key
age-keygen -o ~/.sops/age-key.txt

# Public key (share this)
age-keygen -y ~/.sops/age-key.txt
# age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Set environment variable for decryption
export SOPS_AGE_KEY_FILE=~/.sops/age-key.txt
```

### GPG

```bash
# Generate GPG key
gpg --full-generate-key

# List keys
gpg --list-keys --keyid-format long

# Export public key (share with team)
gpg --armor --export <KEY_ID> > public-key.asc
```

## .sops.yaml Configuration

```yaml
# .sops.yaml — placed at repo root
creation_rules:
  # Encrypt Kubernetes secrets
  - path_regex: k8s/.*secrets.*\.ya?ml$
    encrypted_regex: "^(data|stringData)$"
    age: >-
      age1abc...,
      age1def...

  # Encrypt environment files
  - path_regex: \.env\..*$
    age: age1abc...

  # Encrypt Terraform variable files with sensitive data
  - path_regex: .*\.tfvars$
    encrypted_regex: "^(password|token|secret|key).*$"
    age: age1abc...

  # Encrypt Ansible vault files
  - path_regex: vars/.*vault.*\.ya?ml$
    age: age1abc...

  # Default — encrypt everything
  - path_regex: secrets/.*\.ya?ml$
    age: age1abc...
```

## Usage Examples

### Full File Encryption

```bash
# Encrypt
sops --encrypt secrets.yaml > secrets.enc.yaml

# Decrypt
sops --decrypt secrets.enc.yaml > secrets.yaml

# Edit in-place (opens $EDITOR)
sops secrets.enc.yaml
```

### Partial Encryption (encrypted_regex)

```yaml
# Original file
apiVersion: v1
kind: Secret
metadata:
  name: myapp-secrets
type: Opaque
stringData:
  DB_PASSWORD: "super-secret"
  API_KEY: "token-123"

# After SOPS encryption with encrypted_regex: "^(stringData)$"
# metadata remains plaintext, only stringData is encrypted
```

### Ansible Integration

```yaml
# Use community.sops collection
# requirements.yml
collections:
  - name: community.sops

# Decrypt in playbook
- name: Load encrypted vars
  ansible.builtin.include_vars:
    file: "{{ lookup('community.sops.sops', 'vars/secrets.enc.yaml') }}"
```

### Terraform Integration

```hcl
# Use carlpett/sops provider
terraform {
  required_providers {
    sops = {
      source  = "carlpett/sops"
      version = "~> 1.0"
    }
  }
}

data "sops_file" "secrets" {
  source_file = "secrets.enc.yaml"
}

resource "azurerm_key_vault_secret" "db_password" {
  name         = "db-password"
  value        = data.sops_file.secrets.data["db_password"]
  key_vault_id = azurerm_key_vault.main.id
}
```

### Helm Secrets Plugin

```bash
# Install helm-secrets plugin
helm plugin install https://github.com/jkroepke/helm-secrets

# Encrypt values file
sops --encrypt values-secrets.yaml > values-secrets.enc.yaml

# Deploy with encrypted values
helm secrets upgrade myapp ./chart \
  -f values.yaml \
  -f values-secrets.enc.yaml
```

## CI/CD Integration

### GitHub Actions

```yaml
- name: Decrypt secrets
  env:
    SOPS_AGE_KEY: ${{ secrets.SOPS_AGE_KEY }}
  run: |
    sops --decrypt secrets.enc.yaml > secrets.yaml
```

### GitLab CI

```yaml
decrypt:
  script:
    - export SOPS_AGE_KEY="$SOPS_AGE_KEY"
    - sops --decrypt secrets.enc.yaml > secrets.yaml
```

## Key Rotation

```bash
# Rotate to new key while keeping old key access
sops updatekeys secrets.enc.yaml

# Re-encrypt all files after .sops.yaml change
find . -name "*.enc.yaml" -exec sops updatekeys {} \;
```

## Best Practices

- Store `.sops.yaml` in repo root — defines encryption rules
- Use `encrypted_regex` for partial encryption — keeps diffs readable
- Multiple recipients — team members + CI service key
- Never commit age private keys or GPG secret keys
- Use `SOPS_AGE_KEY` env var in CI (from CI secret store)
- Rotate keys when team members leave
