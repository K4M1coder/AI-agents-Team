---
name: security-hardening
description: "**WORKFLOW SKILL** — Harden operating systems and infrastructure against security benchmarks. USE FOR: CIS Benchmark compliance (Level 1/2), ANSSI-BP-028 hardening, SSH hardening, firewall configuration, SELinux/AppArmor policies, kernel parameters (sysctl), audit logging (auditd), filesystem permissions, user/password policies, PAM configuration, Windows security baselines, automated scanning (OpenSCAP, Lynis). USE WHEN: securing new servers, preparing compliance audits, reviewing system configurations."
argument-hint: "Describe the hardening scope (e.g., 'CIS Level 1 for AlmaLinux 9 servers')"
---

# Security Hardening

Harden operating systems and infrastructure following established security benchmarks.

## When to Use

- Securing newly provisioned servers
- Applying CIS Benchmark controls (Level 1 / Level 2)
- Preparing for compliance audits
- Reviewing and remediating security findings
- Building hardened VM templates (with `packer-imaging` skill)

## Procedure

### 1. Select the Benchmark

| Benchmark | Scope | Authority |
| ----------- | ------- | ----------- |
| CIS Benchmark | OS + services | Center for Internet Security |
| ANSSI-BP-028 | Linux hardening | French ANSSI |
| DISA STIG | US DoD systems | DISA |
| Microsoft Security Baseline | Windows | Microsoft |

### 2. Assess Current State

```bash
# OpenSCAP (RHEL/AlmaLinux)
oscap xccdf eval --profile cis_level1_server \
  --results results.xml --report report.html \
  /usr/share/xml/scap/ssg/content/ssg-almalinux9-ds.xml

# Lynis (cross-platform)
lynis audit system --quiet --no-colors

# Windows — PowerShell DSC
Install-Module -Name SecurityPolicyDsc
Get-DscConfiguration
```

### 3. Apply Hardening Controls

See [CIS/ANSSI controls reference](./references/cis-anssi-controls.md) for specific rules.

**Linux hardening areas:**

| Category | Key Controls |
| ---------- | ------------- |
| SSH | `PermitRootLogin no`, `PasswordAuthentication no`, `MaxAuthTries 3` |
| Firewall | Default deny, explicit allow, rate limiting |
| Kernel | `net.ipv4.ip_forward=0`, `kernel.randomize_va_space=2` |
| Filesystem | `noexec,nosuid,nodev` on `/tmp`, `/var/tmp`, `/dev/shm` |
| Users | `PASS_MAX_DAYS 90`, `PASS_MIN_LEN 14`, `UMASK 027` |
| Audit | `auditd` rules for privileged commands, file access |
| SELinux | `enforcing` mode, custom policies for services |
| Packages | Remove unnecessary packages, disable unused services |

**Windows hardening areas:**

| Category | Key Controls |
| ---------- | ------------- |
| Accounts | Rename Administrator, disable Guest, account lockout |
| Audit | Advanced audit policy, Sysmon deployment |
| Firewall | Windows Firewall profiles enabled, default block inbound |
| Services | Disable unnecessary services (Print Spooler, Remote Registry) |
| Registry | Hardened SMB, LDAP, NTLM settings |
| Updates | WSUS/WU policies, auto-update configuration |

### 4. Validate

```bash
# Re-scan after hardening
oscap xccdf eval --profile cis_level1_server \
  --results after.xml --report after-report.html \
  /usr/share/xml/scap/ssg/content/ssg-almalinux9-ds.xml

# Lynis score comparison
lynis audit system | grep "Hardening index"

# Trivy misconfiguration scan
trivy config /etc/
```

See [scanning tools reference](./references/scanning-tools.md) for tool details.

### 5. Document Exceptions

For controls that cannot be applied:
- **Document the exception**: Which control, why it can't be applied
- **Compensating control**: What alternative mitigation is in place
- **Review cadence**: When to reassess
- **Approval**: Who signed off

## Hardening Automation Strategy

```text
┌─────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│  Packer  │───▶│ Ansible  │───▶│ Validate │───▶│ Template │
│ (build)  │    │(harden)  │    │(OpenSCAP)│    │ (golden) │
└─────────┘    └──────────┘    └──────────┘    └──────────┘
                                                      │
                    ┌──────────┐    ┌──────────┐      │
                    │ Drift    │◀───│ Deploy   │◀─────┘
                    │ (detect) │    │ (TF/Ans) │
                    └──────────┘    └──────────┘
```

## Agent Integration

- **`executant-security-ops`**: Overall security review and risk assessment
- **`executant-platform-ops`**: Apply hardening to Proxmox/vCenter/XCP hosts
- **`ansible-automation`** skill: Write hardening playbooks and roles
- **`packer-imaging`** skill: Bake hardening into golden images
