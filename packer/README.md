# Packer — Golden Image Factory

## Overview

Packer HCL2 templates for building hardened, reproducible VM images across hypervisors (Proxmox VE, VMware vSphere, cloud providers). Images are pre-baked with baseline packages, security hardening, and cloud-init for first-boot customization.

## Directory Structure

```
packer/
├── templates/          # HCL2 template files (one per OS/platform)
└── README.md
```

Planned templates (M2+):

| Template | OS | Platform |
|----------|----|----------|
| `ubuntu-2404-proxmox.pkr.hcl` | Ubuntu 24.04 LTS | Proxmox VE |
| `almalinux-9-proxmox.pkr.hcl` | AlmaLinux 9 | Proxmox VE |
| `ubuntu-2404-vsphere.pkr.hcl` | Ubuntu 24.04 LTS | VMware vSphere |
| `windows-2022-vsphere.pkr.hcl` | Windows Server 2022 | VMware vSphere |

## Build Instructions

```bash
# Validate template syntax
packer validate packer/templates/<template>.pkr.hcl

# Build image (requires hypervisor credentials)
packer build -var-file=packer/vars/dev.pkrvars.hcl packer/templates/<template>.pkr.hcl

# Build with specific variables
packer build \
  -var 'proxmox_url=https://pve.example.com:8006/api2/json' \
  -var 'proxmox_token_id=packer@pam!packer' \
  packer/templates/ubuntu-2404-proxmox.pkr.hcl
```

## Supported OS Families

| Family | Versions | Provisioner |
|--------|----------|-------------|
| Ubuntu/Debian | 22.04, 24.04 | cloud-init + Ansible |
| RHEL/AlmaLinux | 9.x | Kickstart + Ansible |
| Windows Server | 2019, 2022, 2025 | Unattend.xml + PowerShell |

## Conventions

- Templates use HCL2 format exclusively
- Provisioner chain: shell bootstrap → Ansible roles → hardening
- Output images tagged with build date and git commit SHA
- See [naming conventions](../docs/conventions/naming.md)
