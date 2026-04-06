---
name: packer-imaging
description: "**WORKFLOW SKILL** — Build golden VM images with Packer for multi-platform deployment. USE FOR: Packer HCL2 templates, multi-builder configs (Proxmox/vCenter/AWS AMI/Azure), cloud-init integration, provisioner chains (Ansible/shell/PowerShell), post-processors (manifest/checksum), hardening baked into images, image pipeline automation. USE WHEN: building base OS templates, creating golden images, automating VM template lifecycle."
argument-hint: "Describe the image to build (e.g., 'AlmaLinux 9 base image for Proxmox with CIS hardening')"
---

# Packer Imaging

Build reproducible, hardened golden VM images for multi-platform deployment.

## When to Use

- Creating base OS templates for Proxmox, vCenter, XCP-ng, or cloud (AWS/Azure/GCP)
- Baking security hardening into images (CIS, ANSSI-BP-028)
- Automating image pipeline (build → test → promote → distribute)
- Standardizing VM templates across environments

## Procedure

### 1. Define the Image

Determine:
- **Target platform(s)**: Proxmox, vCenter, AWS, Azure, GCP, XCP-ng
- **Base OS**: AlmaLinux 9, Ubuntu 24.04, Debian 12, Windows Server 2022
- **Hardening level**: Minimal (monitoring agent only) vs CIS-hardened vs full baseline
- **Cloud-init**: Required for all Linux templates (cloudbase-init for Windows)

### 2. Write the Template

See [builder patterns reference](./references/builder-patterns.md) for platform-specific builders.

**HCL2 template structure:**
```text
packer/
├── <os>-<platform>.pkr.hcl    # Main template (sources + build blocks)
├── variables.pkr.hcl          # Variable declarations
├── <os>.auto.pkrvars.hcl      # Default variable values
├── http/                      # Autoinstall/Kickstart files
│   ├── ks.cfg                 # RHEL/AlmaLinux kickstart
│   ├── preseed.cfg            # Debian preseed
│   └── user-data              # Ubuntu autoinstall (cloud-init)
├── scripts/                   # Shell provisioner scripts
│   ├── base.sh                # Common setup
│   ├── hardening.sh           # Security hardening
│   └── cleanup.sh             # Template cleanup (cloud-init clean, etc.)
└── ansible/                   # Ansible provisioner playbooks
    └── harden.yml
```

### 3. Configure Provisioners

**Provisioner chain order:**
1. **Shell/PowerShell**: Base OS updates, prerequisite packages
2. **Ansible**: Configuration management, hardening roles
3. **Shell**: Cleanup — cloud-init clean, SSH host keys, machine-id, bash history

```hcl
build {
  sources = ["source.proxmox-iso.almalinux"]

  provisioner "shell" {
    scripts = [
      "scripts/base.sh",
    ]
  }

  provisioner "ansible" {
    playbook_file = "ansible/harden.yml"
    extra_arguments = [
      "--extra-vars", "target_os=almalinux9",
    ]
  }

  provisioner "shell" {
    scripts = [
      "scripts/cleanup.sh",
    ]
  }
}
```

### 4. Validate and Build

```bash
# Format check
packer fmt -check .

# Validate template
packer init .
packer validate .

# Build with logging
PACKER_LOG=1 packer build -force .

# Build specific source only
packer build -only="proxmox-iso.almalinux" .
```

### 5. Post-Build

- **Manifest**: Record build metadata (ID, checksum, timestamp)
- **Checksum**: Generate and store image hash
- **Registry**: Upload to template storage or cloud image registry
- **Test**: Boot a VM from the image, run validation (Molecule, InSpec, Goss)

## Image Lifecycle

```text
┌───────┐    ┌────────┐    ┌──────────┐    ┌──────────┐    ┌───────────┐
│ Build │───▶│Validate│───▶│ Promote  │───▶│Distribute│───▶│ Deprecate │
│(Packer)│   │ (test) │    │(registry)│    │(multi-DC)│    │(lifecycle)│
└───────┘    └────────┘    └──────────┘    └──────────┘    └───────────┘
```

## Cleanup Script (Linux)

```bash
#!/bin/bash
# Must run last — prepares image for templating
# Remove SSH host keys (regenerated on first boot)
rm -f /etc/ssh/ssh_host_*
# Clean cloud-init
cloud-init clean --logs --seed
# Remove machine-id (regenerated on boot)
truncate -s 0 /etc/machine-id
rm -f /var/lib/dbus/machine-id
# Clear logs and history
truncate -s 0 /var/log/*.log
history -c
```

## Agent Integration

- **`executant-infra-architect`**: Review image design and template strategy
- **`executant-security-ops`**: Validate hardening scripts and scan built images
- **`executant-platform-ops`**: Platform-specific builder configuration
- **`ansible-automation`** skill: Write Ansible provisioner playbooks
