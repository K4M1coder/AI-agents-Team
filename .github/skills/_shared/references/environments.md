# Cross-Platform Environment Reference

Shared reference for all skills and agents. Maps each target environment to its management tools, package managers, init systems, firewalls, and IaC providers.

## How to Use This Reference

- Use this file when the question is primarily about the target platform: OS family, virtualization layer, cloud, identity surface, or IaC entry point.
- Use it to choose the right management interface, package manager, service manager, firewall, and infrastructure toolchain for a given environment.

## Boundaries

- This file maps environments and operational surfaces; it does not choose model families.
- Model-family routing belongs in `llm-landscape.md`.
- Framework and runtime stack comparisons belong in `ai-stack.md`.

## Operating Systems

### Windows Desktop

| Aspect | Tools |
| -------- | ------- |
| **Config Management** | PowerShell DSC, Ansible (`win_*` modules), Group Policy (domain-joined) |
| **Package Managers** | winget, chocolatey, scoop |
| **Init System** | Windows Services (`sc.exe`, `Get-Service`) |
| **Firewall** | Windows Defender Firewall (`netsh advfirewall`, `New-NetFirewallRule`) |
| **Shell** | PowerShell 7+, Windows Terminal |
| **Remote Access** | WinRM (Ansible), OpenSSH, RDP |
| **Automation** | PowerShell scripts, Task Scheduler, Ansible `ansible.windows` collection |

### Windows Server

| Aspect | Tools |
| -------- | ------- |
| **Config Management** | PowerShell DSC, Ansible (`win_*` modules), Server Manager, AD/GPO |
| **Package Managers** | winget, chocolatey |
| **Init System** | Windows Services, IIS (web), MSSQL services |
| **Firewall** | Windows Defender Firewall + NSG (Azure), `New-NetFirewallRule` |
| **Roles** | AD DS, DNS, DHCP, File Server, Hyper-V, IIS, WSUS |
| **Remote Access** | WinRM, OpenSSH, RDP, Server Manager Remote |
| **Ansible Collection** | `ansible.windows`, `community.windows`, `microsoft.ad` |

### AlmaLinux / RHEL

| Aspect | Tools |
| -------- | ------- |
| **Config Management** | Ansible (native), Puppet, Rudder |
| **Package Managers** | `dnf`, `rpm`, EPEL repository |
| **Init System** | systemd (`systemctl`) |
| **Firewall** | `firewalld` (default), `nftables` (underlying) |
| **SELinux** | Enforcing by default — `semanage`, `restorecon`, `audit2allow` |
| **Hardening** | CIS Benchmark for RHEL 8/9, ANSSI-BP-028 (intermediate/enhanced) |
| **Ansible Collection** | `ansible.builtin` (yum/dnf), `ansible.posix` (SELinux) |

### Debian / Ubuntu

| Aspect | Tools |
| -------- | ------- |
| **Config Management** | Ansible (native), Puppet |
| **Package Managers** | `apt`, `dpkg`, PPAs (Ubuntu) |
| **Init System** | systemd (`systemctl`) |
| **Firewall** | `ufw` (Ubuntu default), `nftables` |
| **AppArmor** | Enabled by default (Ubuntu) — `aa-status`, `aa-enforce` |
| **Hardening** | CIS Benchmark for Ubuntu/Debian, ANSSI-BP-028 |
| **Ansible Collection** | `ansible.builtin` (apt), `community.general` |

---

## Virtualization Platforms

### VMware vCenter / ESXi

| Aspect | Tools |
| -------- | ------- |
| **CLI** | `govc` (Go vSphere client), PowerCLI (`VMware.PowerCLI` module) |
| **Terraform Provider** | `hashicorp/vsphere` — VMs, networks, storage, templates |
| **Packer Builder** | `vsphere-iso`, `vsphere-clone` |
| **Ansible Collection** | `community.vmware` — `vmware_guest`, `vmware_portgroup`, etc. |
| **API** | vSphere REST API, vSphere Automation SDK (Python) |
| **Networking** | dvSwitch, NSX-T (micro-segmentation), port groups |
| **Storage** | vSAN, VMFS, NFS datastores |
| **HA/DRS** | vSphere HA, DRS (Distributed Resource Scheduler), vMotion |

### Proxmox VE

| Aspect | Tools |
| -------- | ------- |
| **CLI** | `pvesh` (REST API client), `qm` (VM), `pct` (LXC containers) |
| **Terraform Provider** | `telmate/proxmox` or `bpg/proxmox` — VMs, LXC, storage, networks |
| **Packer Builder** | `hashicorp/proxmox` (`proxmox-iso`, `proxmox-clone`) |
| **Ansible Collection** | `community.general.proxmox`, `community.general.proxmox_kvm` |
| **API** | Proxmox REST API (token or PAM auth) |
| **Base OS** | Debian-based — `apt` for packages |
| **Firewall** | `pve-firewall` (cluster/host/VM level) |
| **Storage** | ZFS (local), Ceph (distributed), NFS, iSCSI, LVM-thin |
| **HA** | Proxmox HA Manager, corosync quorum, live migration |

### Vates / XCP-ng (Xen Orchestra)

| Aspect | Tools |
| -------- | ------- |
| **CLI** | `xe` (XAPI CLI), Xen Orchestra web UI |
| **Terraform Provider** | `vatesfr/xenorchestra` — VMs, networks, templates, storage |
| **Packer Builder** | Community `xenserver` builder |
| **Ansible** | `xe` commands via `ansible.builtin.command/shell` |
| **API** | XAPI (XML-RPC), Xen Orchestra REST API |
| **Base OS** | CentOS-based — `dnf`/`yum` for packages |
| **Features** | VM snapshots, replication, backup (Xen Orchestra Backup), live migration |
| **Storage** | Local LVM, NFS, iSCSI, SMB, GlusterFS |
| **HA** | XCP-ng HA with shared storage, Xen Orchestra continuous replication |

---

## Cloud Platforms

### Microsoft Azure

| Aspect | Tools |
| -------- | ------- |
| **CLI** | `az` CLI, Azure PowerShell (`Az` module) |
| **Terraform Provider** | `hashicorp/azurerm` (resources), `hashicorp/azuread` (EntraID) |
| **IaC Alternative** | Bicep (ARM template DSL), ARM templates (JSON) |
| **Ansible Collection** | `azure.azcollection` |
| **Key Services** | VMs, AKS, App Service, Functions, Storage, VNets, NSGs |
| **Identity** | EntraID (Azure AD), Managed Identity, RBAC, Conditional Access |
| **Networking** | VNet, NSG, Azure Firewall, Application Gateway, Front Door |
| **Monitoring** | Azure Monitor, Log Analytics, Application Insights |

### Microsoft 365 / Entra ID

| Aspect | Tools |
| -------- | ------- |
| **CLI** | Microsoft Graph CLI (`mgc`), Azure AD PowerShell, Microsoft Graph PowerShell SDK |
| **API** | Microsoft Graph REST API v1.0/beta |
| **Terraform Provider** | `hashicorp/azuread` (users, groups, apps, policies) |
| **Key Services** | Exchange Online, SharePoint, Teams, Intune, Defender for O365 |
| **Identity** | Conditional Access, MFA, PIM (Privileged Identity Management) |
| **Compliance** | DLP, Information Protection, eDiscovery, Audit Log |
| **Automation** | Power Automate, Logic Apps, Graph API batch requests |

### Google Cloud Platform (GCP)

| Aspect | Tools |
| -------- | ------- |
| **CLI** | `gcloud` CLI, `gsutil` (storage), `bq` (BigQuery) |
| **Terraform Provider** | `hashicorp/google`, `hashicorp/google-beta` |
| **Ansible Collection** | `google.cloud` |
| **Key Services** | Compute Engine, GKE, Cloud Run, Cloud Functions, Cloud Storage |
| **Identity** | IAM, Workload Identity Federation, Organization policies |
| **Networking** | VPC, Cloud NAT, Cloud Armor (WAF), Cloud DNS |
| **Monitoring** | Cloud Monitoring, Cloud Logging, Cloud Trace |

### Amazon Web Services (AWS)

| Aspect | Tools |
| -------- | ------- |
| **CLI** | `aws` CLI v2, AWS CDK |
| **Terraform Provider** | `hashicorp/aws` |
| **IaC Alternative** | CloudFormation (YAML/JSON), AWS CDK (TypeScript/Python) |
| **Ansible Collection** | `amazon.aws`, `community.aws` |
| **Key Services** | EC2, EKS, Lambda, S3, RDS, VPC, ALB/NLB |
| **Identity** | IAM, SSO (Identity Center), STS, OIDC federation |
| **Networking** | VPC, Security Groups, NACLs, Transit Gateway, Route 53 |
| **Monitoring** | CloudWatch, CloudTrail, X-Ray, AWS Config |

---

## Common IaC Patterns Across Platforms

### Terraform Multi-Provider Setup

```hcl
# Example: Multi-provider Terraform configuration
terraform {
  required_providers {
    proxmox  = { source = "bpg/proxmox" }
    vsphere  = { source = "hashicorp/vsphere" }
    azurerm  = { source = "hashicorp/azurerm" }
    azuread  = { source = "hashicorp/azuread" }
    google   = { source = "hashicorp/google" }
    aws      = { source = "hashicorp/aws" }
    xenorchestra = { source = "vatesfr/xenorchestra" }
  }
}
```

### Ansible Multi-OS Task Pattern

```yaml
# Example: Package installation across OS families
- name: Install monitoring agent
  ansible.builtin.package:
    name: "{{ monitoring_agent_package }}"
    state: present

# In group_vars:
# RedHat: monitoring_agent_package: node_exporter
# Debian: monitoring_agent_package: prometheus-node-exporter
# Windows: Use win_chocolatey module instead
```

### Cloud-Init Template (Universal)

```yaml
#cloud-config
package_update: true
packages:
  - qemu-guest-agent  # Proxmox/KVM
  - open-vm-tools     # vCenter/ESXi
users:
  - name: ansible
    ssh_authorized_keys:
      - "{{ ssh_public_key }}"
    sudo: ALL=(ALL) NOPASSWD:ALL
```

---

## Related Shared References

- `ai-stack.md` — frameworks, inference stacks, quantization, and hardware matrix
- `llm-landscape.md` — model-family routing and deployment selection
