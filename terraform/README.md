# Terraform — Infrastructure as Code

## Overview

Declarative infrastructure provisioning using Terraform (>= 1.6.0). Provider-agnostic module design per [ADR-002](../docs/adr/ADR-002-network-mvp-scope.md), with vendor-specific implementations planned for M1.1+.

## Directory Structure

```
terraform/
├── envs/
│   ├── dev/
│   │   └── network.tfvars      # Dev environment variables
│   └── preprod/
│       └── network.tfvars      # Pre-production variables
├── modules/
│   └── network/
│       ├── main.tf             # Core network module logic
│       ├── variables.tf        # Input variable declarations
│       └── outputs.tf          # Output definitions
└── README.md
```

## Quick Start

```bash
# Format check
terraform -chdir=terraform/modules/network fmt -check -recursive

# Initialize (no backend for local validation)
terraform -chdir=terraform/modules/network init -backend=false

# Validate syntax and configuration
terraform -chdir=terraform/modules/network validate

# Plan with dev environment
terraform -chdir=terraform/modules/network plan \
  -var-file=../../envs/dev/network.tfvars

# Plan with preprod environment
terraform -chdir=terraform/modules/network plan \
  -var-file=../../envs/preprod/network.tfvars
```

## Module: network

Provider-agnostic network module defining CIDR allocation, subnet layout (mgmt/prod/dmz tiers), and computed gateway/broadcast addresses. Outputs structured data for downstream consumption by vendor-specific modules.

**Inputs**: `network_cidr`, `subnets` (list of name/cidr/tier objects), `tags`
**Outputs**: `network_cidr`, `subnet_count`, `network_summary`, `subnet_details`, `validated_plan`

## Environments

| Env | CIDR | Subnets |
|-----|------|---------|
| dev | 10.20.0.0/16 | mgmt-dev, prod-dev, dmz-dev |
| preprod | 10.30.0.0/16 | mgmt-preprod, prod-preprod, dmz-preprod |

## Conventions

- Module names: lowercase, hyphen-separated
- Tag `managed_by = "terraform"` on all resources
- See [naming conventions](../docs/conventions/naming.md)
