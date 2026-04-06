# Vault / OpenBao Patterns Reference

## Architecture

```text
┌─────────────┐     ┌──────────┐     ┌───────────────┐
│   Clients   │────▶│  Vault   │────▶│   Storage     │
│ (apps, CI)  │     │ (server) │     │ (Consul/Raft) │
└─────────────┘     └──────────┘     └───────────────┘
                         │
                    ┌────┴────┐
                    │  Audit  │
                    │  (file) │
                    └─────────┘
```

## Server Configuration (config.hcl)

```hcl
# Production configuration
storage "raft" {
  path    = "/opt/vault/data"
  node_id = "vault-01"
}

listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_cert_file = "/opt/vault/tls/cert.pem"
  tls_key_file  = "/opt/vault/tls/key.pem"
}

api_addr     = "https://vault.example.com:8200"
cluster_addr = "https://vault-01.example.com:8201"

ui = true

# Audit to file
audit {
  type = "file"
  options {
    file_path = "/var/log/vault/audit.log"
  }
}
```

## Auth Methods

### AppRole (for CI/CD and services)

```bash
# Enable AppRole
vault auth enable approle

# Create role
vault write auth/approle/role/myapp \
  token_policies="myapp-policy" \
  token_ttl=1h \
  token_max_ttl=4h \
  secret_id_ttl=720h \
  secret_id_num_uses=0

# Get role ID
vault read auth/approle/role/myapp/role-id

# Generate secret ID
vault write -f auth/approle/role/myapp/secret-id

# Login
vault write auth/approle/login \
  role_id="$ROLE_ID" \
  secret_id="$SECRET_ID"
```

### Kubernetes Auth

```bash
# Enable Kubernetes auth
vault auth enable kubernetes

# Configure (from within the cluster)
vault write auth/kubernetes/config \
  kubernetes_host="https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT"

# Create role bound to service account
vault write auth/kubernetes/role/myapp \
  bound_service_account_names=myapp-sa \
  bound_service_account_namespaces=myapp \
  policies=myapp-policy \
  ttl=1h
```

### OIDC (for users)

```bash
vault auth enable oidc

vault write auth/oidc/config \
  oidc_discovery_url="https://login.microsoftonline.com/$TENANT_ID/v2.0" \
  oidc_client_id="$CLIENT_ID" \
  oidc_client_secret="$CLIENT_SECRET" \
  default_role="default"

vault write auth/oidc/role/default \
  bound_audiences="$CLIENT_ID" \
  allowed_redirect_uris="https://vault.example.com:8200/ui/vault/auth/oidc/oidc/callback" \
  user_claim="email" \
  policies="default"
```

## Secrets Engines

### KV v2 (Static Secrets)

```bash
# Enable KV v2
vault secrets enable -path=secret kv-v2

# Write secret
vault kv put secret/myapp/config \
  db_host="db.example.com" \
  db_port="5432" \
  db_password="s3cret"

# Read secret
vault kv get secret/myapp/config

# Read specific version
vault kv get -version=2 secret/myapp/config

# Delete (soft)
vault kv delete secret/myapp/config

# Undelete
vault kv undelete -versions=3 secret/myapp/config
```

### Database (Dynamic Credentials)

```bash
# Enable database engine
vault secrets enable database

# Configure PostgreSQL connection
vault write database/config/mydb \
  plugin_name=postgresql-database-plugin \
  allowed_roles="myapp-role" \
  connection_url="postgresql://{{username}}:{{password}}@db.example.com:5432/mydb?sslmode=require" \
  username="vault_admin" \
  password="admin_password"

# Create role with dynamic creds
vault write database/roles/myapp-role \
  db_name=mydb \
  creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
  default_ttl="1h" \
  max_ttl="24h"

# Get dynamic credentials
vault read database/creds/myapp-role
```

### Transit (Encryption as a Service)

```bash
# Enable transit
vault secrets enable transit

# Create encryption key
vault write -f transit/keys/myapp

# Encrypt
vault write transit/encrypt/myapp \
  plaintext=$(echo "secret data" | base64)

# Decrypt
vault write transit/decrypt/myapp \
  ciphertext="vault:v1:..."
```

## Policies

```hcl
# myapp-policy.hcl
# Read-only access to app secrets
path "secret/data/myapp/*" {
  capabilities = ["read", "list"]
}

# Dynamic database credentials
path "database/creds/myapp-role" {
  capabilities = ["read"]
}

# PKI certificate issuance
path "pki_int/issue/server" {
  capabilities = ["create", "update"]
}

# Deny access to other paths (implicit)
```

```bash
# Apply policy
vault policy write myapp myapp-policy.hcl
```

## External Secrets Operator (ESO)

```yaml
# SecretStore — connects ESO to Vault
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: vault-backend
  namespace: myapp
spec:
  provider:
    vault:
      server: "https://vault.example.com:8200"
      path: "secret"
      version: "v2"
      auth:
        kubernetes:
          mountPath: "kubernetes"
          role: "myapp"
          serviceAccountRef:
            name: myapp-sa
---
# ExternalSecret — syncs a Vault secret to K8s Secret
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: myapp-secrets
  namespace: myapp
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: vault-backend
    kind: SecretStore
  target:
    name: myapp-secrets
    creationPolicy: Owner
  data:
    - secretKey: DB_PASSWORD
      remoteRef:
        key: myapp/config
        property: db_password
```text
