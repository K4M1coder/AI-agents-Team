---
name: terraform-provisioning
description: "**WORKFLOW SKILL** — Write, validate, plan, and apply Terraform/OpenTofu infrastructure. USE FOR: module authoring, provider configuration (AWS/Azure/GCP/Proxmox/vCenter/XCP-ng), state backend setup, Terragrunt environment management, variable design, output wiring, import existing resources, drift detection, workspace strategies, module registry publishing. USE WHEN: provisioning cloud or on-prem infrastructure, managing resource lifecycle, designing multi-environment layouts."
argument-hint: "Describe the infrastructure to provision (e.g., 'Proxmox VM cluster with Ceph storage')"
---

# Terraform Provisioning

Write, validate, plan, and apply Terraform/OpenTofu infrastructure code for cloud and on-premises platforms.

## When to Use

- Provisioning cloud resources (VMs, networks, storage, managed services)
- Creating on-prem VMs (Proxmox, vCenter, XCP-ng)
- Managing DNS, certificates, identity (EntraID, IAM)
- Multi-environment promotion (dev → staging → prod)
- Importing existing infrastructure under IaC management

## Procedure

### 1. Design the Module Structure

See [module structure reference](./references/module-structure.md) for layout patterns.

**Decision: Root module vs reusable module?**
| Type | When | Structure |
| ------ | ------ | ----------- |
| Root module | Single deployment, environment-specific | `main.tf`, `variables.tf`, `outputs.tf`, `terraform.tf` |
| Reusable module | Multi-use, parameterized | `modules/<name>/` with docs |
| Terragrunt | Multi-env with DRY config | `terragrunt.hcl` per environment |

### 2. Select Provider

See [provider patterns reference](./references/provider-patterns.md) for provider-specific configurations.

```hcl
terraform {
  required_version = ">= 1.5"
  required_providers {
    # Choose based on target platform
  }
}
```

### 3. Write the Configuration

**Variable design rules:**
- Required vars: no default — force explicit input
- Optional vars: sensible defaults that work for dev
- Sensitive vars: `sensitive = true` — never in logs
- Validation blocks for constraints (CIDR ranges, naming patterns)
- Use `object({})` types for related parameters

**Resource patterns:**
- Use `for_each` over `count` (stable addressing)
- Tag everything: `Name`, `Environment`, `Owner`, `ManagedBy=terraform`
- Use `lifecycle { prevent_destroy = true }` for critical resources
- Use `data` sources to reference existing infrastructure
- Keep resource names descriptive: `azurerm_virtual_network.main`

### 4. Configure State Backend

```hcl
# Azure Blob Storage
backend "azurerm" {
  resource_group_name  = "tfstate-rg"
  storage_account_name = "tfstate"
  container_name       = "state"
  key                  = "project/env.tfstate"
}

# AWS S3 + DynamoDB locking
backend "s3" {
  bucket         = "tfstate-bucket"
  key            = "project/env.tfstate"
  region         = "eu-west-1"
  dynamodb_table = "terraform-locks"
  encrypt        = true
}
```

### 5. Validate and Plan

```bash
# Format check
terraform fmt -check -recursive

# Validate syntax and providers
terraform init
terraform validate

# Plan with output
terraform plan -out=tfplan

# Security scan
trivy config .
# or
checkov -d .
```

### 6. Apply

```bash
# Apply saved plan (CI/CD)
terraform apply tfplan

# Apply with auto-approve (only in automation with prior plan review)
terraform apply -auto-approve

# Target specific resource
terraform apply -target=module.network
```

### 7. Drift Detection

```bash
# Detect drift
terraform plan -detailed-exitcode
# Exit code 2 = drift detected

# Refresh state from real infrastructure
terraform refresh
```

## State Management Best Practices

- **Remote state**: Always use remote backend (never local in teams)
- **State locking**: Enable DynamoDB (AWS) or blob lease (Azure)
- **State isolation**: One state per environment per component
- **State encryption**: Enable at-rest encryption on backend
- **Import**: `terraform import <address> <id>` for existing resources
- **Move**: `terraform state mv` for refactoring without destroy

## Anti-Patterns

- Monolithic state file (split by component/layer)
- Hardcoded values (use variables and data sources)
- Nested provider configs in modules (pass providers from root)
- `terraform destroy` without confirmation in production
- Storing `.tfstate` in git
- Using `count` for resources that may be reordered

## Agent Integration

- **`executant-infra-architect`**: Review module design and architecture decisions
- **`executant-security-ops`**: Scan configurations with Trivy/Checkov/tfsec
- **`executant-cloud-ops`**: Provider-specific best practices (Azure, AWS, GCP)
- **`executant-platform-ops`**: On-prem provider configs (Proxmox, vCenter, XCP-ng)
