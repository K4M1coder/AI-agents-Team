---
name: virtualization-platform
description: "**WORKFLOW SKILL** — Manage VM/container lifecycle on Proxmox VE, VMware vCenter, Vates/XCP-ng, and Hyper-V. USE FOR: hypervisor configuration, VM provisioning, live migration, storage management (ZFS/Ceph/vSAN), LXC containers, HA clusters, template management, cloud-init, GPU passthrough/vGPU, backup strategies (PBS, Veeam, XOA). USE WHEN: managing on-premises virtualization, building golden images, configuring storage pools, or planning hypervisor HA."
argument-hint: "Describe the virtualization task (e.g., 'Proxmox HA cluster with Ceph storage and GPU passthrough')"
---

# Virtualization Platform

Manage VM and container lifecycle on on-premises hypervisors: Proxmox VE, VMware vCenter/ESXi, Vates/XCP-ng, and Hyper-V.

## When to Use

- Provisioning VMs or LXC containers on hypervisors
- Configuring hypervisor storage (ZFS, Ceph, vSAN, NFS, iSCSI)
- Setting up HA clusters and live migration
- Managing golden images and templates
- Configuring GPU passthrough or vGPU
- Planning backup and disaster recovery
- Troubleshooting hypervisor-level issues

## Procedure

### 1. Identify the Platform

| Hypervisor | CLI | IaC Provider | API |
| ------------ | ----- | -------------- | ----- |
| Proxmox VE | `qm`, `pct`, `pvesh` | `bpg/proxmox` | REST API |
| VMware vCenter | `govc`, PowerCLI | `hashicorp/vsphere` | SOAP/REST |
| Vates/XCP-ng | `xe`, Xen Orchestra | `vatesfr/xenorchestra` | XAPI |
| Hyper-V | `PowerShell` | — | WMI/CIM |

### 2. Storage Configuration

#### Proxmox Storage
```bash
# Create ZFS pool
zpool create -f rpool mirror /dev/sda /dev/sdb
pvesm add zfspool local-zfs -pool rpool

# Add Ceph storage
pveceph install
pveceph init
pveceph createmon
pveceph createosd /dev/sdc
pveceph pool create vm-pool
```

#### Storage Decision Matrix

| Backend | Use Case | Performance | Redundancy |
| --------- | ---------- | ------------- | ------------ |
| ZFS (mirror/raidz) | Local fast storage | High (NVMe/SSD) | Mirror/raidz |
| Ceph (RBD) | Shared multi-node | Medium-High | Replicated |
| vSAN | VMware distributed | High | Erasure/mirror |
| NFS | Shared templates/ISOs | Medium | Depends on NAS |
| iSCSI | Block-level shared | Medium-High | SAN-dependent |
| LVM-Thin | Local thin provisioning | High | None (local) |

### 3. VM Provisioning

#### Proxmox
```bash
# Create VM from template
qm clone 9000 100 --name my-vm --full
qm set 100 --memory 4096 --cores 4 --sockets 1
qm set 100 --net0 virtio,bridge=vmbr0,tag=20
qm set 100 --ipconfig0 ip=10.0.20.100/24,gw=10.0.20.1
qm start 100
```

#### Terraform (Proxmox)
```hcl
resource "proxmox_virtual_environment_vm" "server" {
  name      = "my-server"
  node_name = "pve-01"

  clone {
    vm_id = 9000  # template ID
  }

  cpu {
    cores   = 4
    sockets = 1
    type    = "host"
  }

  memory {
    dedicated = 4096
  }

  network_device {
    bridge  = "vmbr0"
    vlan_id = 20
  }

  initialization {
    ip_config {
      ipv4 {
        address = "10.0.20.100/24"
        gateway = "10.0.20.1"
      }
    }
    user_data_file_id = proxmox_virtual_environment_file.cloud_init.id
  }
}
```

### 4. High Availability

#### Proxmox HA
```bash
# Check quorum
pvecm status

# Add VM to HA group
ha-manager add vm:100 --group production --state started
ha-manager groupadd production --nodes pve-01,pve-02,pve-03

# Test migration
qm migrate 100 pve-02 --online
```

#### vSphere HA/DRS
- **HA**: Automatic VM restart on host failure
- **DRS**: Automatic VM placement based on resource usage
- **Affinity rules**: Keep related VMs together or apart
- **vMotion**: Zero-downtime live migration (requires shared storage or vSAN)

### 5. GPU Passthrough / vGPU

```bash
# Proxmox — PCI passthrough
# Enable IOMMU in GRUB
# /etc/default/grub: GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt"
update-grub

# Add GPU to VM
qm set 100 --hostpci0 0000:01:00,pcie=1,x-vga=1
```

| Mode | Description | Multi-VM | Performance |
| ------ | ------------- | ---------- | ------------- |
| Passthrough | Full GPU to one VM | No | 100% |
| vGPU (NVIDIA GRID) | Shared GPU partitions | Yes | ~80-95% |
| SR-IOV | Hardware virtual functions | Yes | ~90-95% |

### 6. Backup and DR

| Platform | Tool | Type | Target |
| ---------- | ------ | ------ | -------- |
| Proxmox | PBS (Proxmox Backup Server) | Incremental, dedup | PBS, NFS, S3 |
| Proxmox | vzdump | Full/snapshot | Local, NFS, PBS |
| vSphere | Veeam, VADP | CBT incremental | Repository |
| XCP-ng | Xen Orchestra Backup | Delta, CR | NFS, S3, SMB |

```bash
# Proxmox — scheduled backup
vzdump 100 --storage pbs --mode snapshot --compress zstd
# PBS retention: keep-last=7, keep-weekly=4, keep-monthly=6
```

### 7. LXC Containers (Proxmox)

```bash
# Create unprivileged container
pct create 200 local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst \
  --hostname my-ct \
  --memory 2048 \
  --cores 2 \
  --rootfs local-zfs:8 \
  --net0 name=eth0,bridge=vmbr0,ip=10.0.20.200/24,gw=10.0.20.1 \
  --unprivileged 1
pct start 200
```

## Cloud-Init Templates

```yaml
# /var/lib/vz/snippets/cloud-init-base.yml
#cloud-config
package_update: true
packages:
  - qemu-guest-agent
  - curl
  - vim
users:
  - name: admin
    groups: sudo
    shell: /bin/bash
    ssh_authorized_keys:
      - ssh-ed25519 AAAA...
runcmd:
  - systemctl enable --now qemu-guest-agent
```

## Anti-Patterns

- Running VMs without resource limits (CPU/memory contention)
- Using thick provisioning when thin is available
- No HA for production workloads
- Storing backups on the same storage as VMs
- Single storage pool for everything (separate ISO, templates, VMs, backups)
- GPU passthrough without IOMMU groups verification
- Running privileged LXC containers unnecessarily
- Not testing backup restoration regularly

## Agent Integration

- **`executant-infra-architect`**: Architecture decisions for hypervisor selection and storage design
- **`executant-security-ops`**: Host hardening, VM isolation, compliance scanning
- **`executant-gpu-infra`**: GPU passthrough/vGPU configuration and hardware requirements
- **`executant-network-ops`**: Hypervisor networking (bridges, VLANs, pve-firewall, dvSwitch)
- **`executant-observability-ops`**: Hypervisor metrics, storage monitoring, capacity alerts
- **`executant-cloud-ops`**: Hybrid cloud patterns, cloud ↔ on-prem connectivity
