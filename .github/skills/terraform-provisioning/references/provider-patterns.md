# Terraform Provider Patterns Reference

## On-Premises Providers

### Proxmox VE (bpg/proxmox)

```hcl
terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.60"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox_url     # https://pve.example.com:8006
  username = var.proxmox_user    # user@pam or user@pve
  password = var.proxmox_password
  insecure = false               # Set true only for self-signed certs
}

resource "proxmox_virtual_environment_vm" "example" {
  name      = "vm-example"
  node_name = "pve-node-01"

  clone {
    vm_id = 9000  # Template ID
  }

  cpu {
    cores = 4
    type  = "host"
  }

  memory {
    dedicated = 8192
  }

  disk {
    datastore_id = "local-zfs"
    size         = 50
    interface    = "scsi0"
  }

  network_device {
    bridge  = "vmbr0"
    vlan_id = 100
  }

  initialization {
    ip_config {
      ipv4 {
        address = "10.0.100.10/24"
        gateway = "10.0.100.1"
      }
    }
    user_data_file_id = proxmox_virtual_environment_file.cloud_init.id
  }
}
```

### VMware vSphere

```hcl
terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 2.8"
    }
  }
}

provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = false
}

resource "vsphere_virtual_machine" "example" {
  name             = "vm-example"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = "Production/WebServers"

  num_cpus = 4
  memory   = 8192
  guest_id = "rhel9_64Guest"

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = "vmxnet3"
  }

  disk {
    label            = "disk0"
    size             = 50
    thin_provisioned = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    customize {
      linux_options {
        host_name = "vm-example"
        domain    = "example.com"
      }
      network_interface {
        ipv4_address = "10.0.1.10"
        ipv4_netmask = 24
      }
      ipv4_gateway = "10.0.1.1"
    }
  }
}
```

### Xen Orchestra (vatesfr/xenorchestra)

```hcl
terraform {
  required_providers {
    xenorchestra = {
      source  = "vatesfr/xenorchestra"
      version = "~> 0.28"
    }
  }
}

provider "xenorchestra" {
  url      = var.xoa_url      # wss://xoa.example.com
  username = var.xoa_user
  password = var.xoa_password
  insecure = false
}

resource "xenorchestra_vm" "example" {
  name_label       = "vm-example"
  template         = data.xenorchestra_template.template.id
  cloud_config     = xenorchestra_cloud_config.config.template
  memory_max       = 8 * 1024 * 1024 * 1024  # 8 GB in bytes
  cpus             = 4

  network {
    network_id = data.xenorchestra_network.network.id
  }

  disk {
    sr_id      = data.xenorchestra_sr.sr.id
    name_label = "vm-example-disk"
    size       = 50 * 1024 * 1024 * 1024  # 50 GB in bytes
  }
}
```

## Cloud Providers

### Azure (azurerm + azuread)

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.50"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "azuread" {
  tenant_id = var.tenant_id
}
```

### AWS

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "terraform"
      Project     = var.project_name
    }
  }
}
```

### GCP

```hcl
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.20"
    }
  }
}

provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}
```

## OpenTofu Compatibility

OpenTofu is a drop-in replacement for Terraform. Key differences:

- Binary: `tofu` instead of `terraform`
- Registry: `registry.opentofu.org` (mirrors HashiCorp registry)
- State encryption: Built-in (not available in Terraform OSS)
- License: MPL-2.0 (vs BSL for Terraform 1.6+)

```bash
# Same commands, different binary
tofu init
tofu plan -out=tfplan
tofu apply tfplan
```text
