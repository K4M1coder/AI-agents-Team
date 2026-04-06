---
name: secrets-management
description: "**WORKFLOW SKILL** — Manage secrets, PKI, and identity across infrastructure. USE FOR: HashiCorp Vault/OpenBao configuration, SOPS-encrypted files, PKI/CA management, workload identity (OIDC), Kubernetes secrets integration (CSI driver, External Secrets Operator), Ansible Vault, environment variable hygiene, secret rotation, transit encryption, dynamic database credentials. USE WHEN: storing/rotating secrets, setting up Vault, encrypting config files, issuing certificates, configuring workload identity."
argument-hint: "Describe the secrets task (e.g., 'SOPS-encrypted Kubernetes secrets with age key')"
---

# Secrets Management

Manage secrets, certificates, and identity following zero-trust principles.

## When to Use

- Setting up or configuring HashiCorp Vault / OpenBao
- Encrypting configuration files with SOPS
- Managing PKI / Certificate Authority
- Configuring workload identity (OIDC federation)
- Integrating secrets into Kubernetes or CI/CD
- Rotating credentials or auditing secret access

## Procedure

### 1. Choose the Strategy

| Method | Best For | Complexity |
| -------- | ---------- | ------------ |
| SOPS + age/GPG | Small teams, Git-encrypted configs | Low |
| Ansible Vault | Ansible-managed secrets | Low |
| Vault/OpenBao | Enterprise, dynamic secrets, PKI | High |
| Cloud KMS | Cloud-native workloads | Medium |
| External Secrets Operator | K8s + any secret backend | Medium |

### 2. SOPS Workflow

See [SOPS configuration reference](./references/sops-config.md).

```bash
# Encrypt with age
sops --encrypt --age $(cat ~/.sops/age-key.pub) secrets.yaml > secrets.enc.yaml

# Decrypt
sops --decrypt secrets.enc.yaml

# Edit in-place
sops secrets.enc.yaml

# Encrypt specific keys only (partial encryption)
sops --encrypt --encrypted-regex '^(password|token|key)$' config.yaml > config.enc.yaml
```

### 3. Vault/OpenBao Setup

See [Vault patterns reference](./references/vault-patterns.md).

**Core concepts:**
- **Secrets engines**: KV, PKI, database, transit, SSH
- **Auth methods**: Token, AppRole, OIDC, Kubernetes, LDAP
- **Policies**: Path-based ACL (`path "secret/data/myapp/*" { capabilities = ["read"] }`)
- **Audit**: Every access logged

### 4. Kubernetes Integration

**Order of preference:**
1. External Secrets Operator (ESO) — syncs from Vault/cloud to K8s Secrets
2. Vault CSI Provider — injects secrets as volumes
3. Vault Agent Injector — sidecar with templated secrets
4. Sealed Secrets — encrypted in Git, decrypted in-cluster

### 5. PKI / Certificates

```bash
# Vault PKI engine
vault secrets enable pki
vault secrets tune -max-lease-ttl=87600h pki

# Generate root CA
vault write pki/root/generate/internal \
  common_name="Example Root CA" \
  ttl=87600h

# Configure intermediate CA
vault secrets enable -path=pki_int pki
vault write pki_int/intermediate/generate/internal \
  common_name="Example Intermediate CA"

# Issue certificate
vault write pki_int/issue/server \
  common_name="app.example.com" \
  ttl=720h
```

### 6. Secret Rotation

| Secret Type | Rotation Method | Frequency |
| ------------ | ----------------- | ----------- |
| API keys | Vault dynamic secrets | On-demand |
| DB passwords | Vault database engine | 24h lease |
| TLS certs | Vault PKI auto-renewal | 30 days before expiry |
| SSH keys | Vault SSH signed keys | Per-session |
| Tokens | OIDC federation | Short-lived (1h) |

## Anti-Patterns

- Secrets in environment variables visible in process lists
- Plaintext secrets in Git (even in private repos)
- Long-lived static credentials
- Shared service accounts across environments
- Secrets in Docker image layers
- Skipping audit logging for secret access
- Self-signed certs without proper CA chain

## Agent Integration

- **`executant-secrets-manager`** agent: Vault/OpenBao configuration and PKI operations
- **`executant-security-ops`**: Review secrets architecture and audit policies
- **`executant-ci-cd-ops`**: Integrate secret injection into CI/CD pipelines
- **`kubernetes-orchestration`** skill: K8s secrets integration (ESO, CSI)
