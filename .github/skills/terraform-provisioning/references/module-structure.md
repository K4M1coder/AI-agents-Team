# Terraform Module Structure Reference

## Root Module Layout

```text
project/
├── terraform.tf        # Required providers, backend config
├── main.tf             # Primary resources
├── variables.tf        # Input variable declarations
├── outputs.tf          # Output value declarations
├── locals.tf           # Computed local values
├── data.tf             # Data source lookups
├── versions.tf         # Version constraints (alt: in terraform.tf)
├── terraform.tfvars    # Variable values (DO NOT commit secrets)
├── .terraform.lock.hcl # Dependency lock file (commit this)
└── modules/            # Local reusable modules
    └── <name>/
```

## Reusable Module Layout

```text
modules/<module_name>/
├── main.tf             # Resources
├── variables.tf        # Input variables with descriptions + validation
├── outputs.tf          # Output values
├── versions.tf         # Provider requirements (no backend!)
├── README.md           # Usage documentation
└── examples/           # Example usage configurations
    └── basic/
        └── main.tf
```

## Multi-Environment with Terragrunt

```text
infrastructure/
├── terragrunt.hcl           # Root config (remote state, provider)
├── modules/                  # Reusable modules
│   ├── networking/
│   ├── compute/
│   └── database/
└── environments/
    ├── dev/
    │   ├── terragrunt.hcl    # Environment-level config
    │   ├── networking/
    │   │   └── terragrunt.hcl
    │   └── compute/
    │       └── terragrunt.hcl
    ├── staging/
    │   ├── terragrunt.hcl
    │   ├── networking/
    │   │   └── terragrunt.hcl
    │   └── compute/
    │       └── terragrunt.hcl
    └── prod/
        └── ...
```

### Root terragrunt.hcl

```hcl
remote_state {
  backend = "azurerm"
  config = {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstate${get_env("ENV", "dev")}"
    container_name       = "state"
    key                  = "${path_relative_to_include()}/terraform.tfstate"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}
EOF
}
```

### Component terragrunt.hcl

```hcl
include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules//networking"
}

inputs = {
  vnet_name     = "vnet-${get_env("ENV", "dev")}"
  address_space = ["10.0.0.0/16"]
  location      = "westeurope"
}

dependency "resource_group" {
  config_path = "../resource-group"
}
```

## Variable Patterns

### Required Variable

```hcl
variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}
```

### Complex Variable with Object Type

```hcl
variable "vm_config" {
  description = "VM configuration"
  type = object({
    name     = string
    cpu      = number
    memory   = number
    disk_gb  = number
    os_image = string
    network  = string
    tags     = map(string)
  })

  default = {
    name     = "default-vm"
    cpu      = 2
    memory   = 4096
    disk_gb  = 50
    os_image = "almalinux-9"
    network  = "default"
    tags     = {}
  }
}
```

### Sensitive Variable

```hcl
variable "db_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.db_password) >= 16
    error_message = "Password must be at least 16 characters."
  }
}
```

## Output Patterns

```hcl
output "vm_ip" {
  description = "Primary IP address of the VM"
  value       = azurerm_linux_virtual_machine.main.private_ip_address
}

output "connection_string" {
  description = "Database connection string"
  value       = "postgresql://${var.db_user}@${azurerm_postgresql_server.main.fqdn}:5432/${var.db_name}"
  sensitive   = true
}
```text
