---
name: ansible-automation
description: "**WORKFLOW SKILL** — Write, lint, test, and deploy Ansible automation. USE FOR: playbook authoring, role/collection structure, inventory management (static/dynamic), Jinja2 templating, Molecule testing, multi-OS support (RHEL/AlmaLinux/Debian/Ubuntu/Windows), vault encryption, handler patterns, fact gathering, callback plugins, AWX/AAP integration. USE WHEN: automating server configuration, deploying software, enforcing compliance, managing multi-OS fleets."
argument-hint: "Describe the automation task (e.g., 'harden SSH on all Linux servers')"
---

# Ansible Automation

Write, lint, test, and deploy Ansible playbooks, roles, and collections following best practices.

## When to Use

- Configuring servers (packages, files, services, users)
- Enforcing compliance baselines (CIS, ANSSI-BP-028)
- Deploying applications across multi-OS fleets
- Managing inventory (static, dynamic, cloud-based)
- Automating operational procedures (patching, backups, rotation)

## Procedure

### 1. Scope the Automation

Determine:
- **Target OS families**: RHEL/AlmaLinux, Debian/Ubuntu, Windows
- **Scope**: Single task (ad-hoc) vs reusable role vs collection
- **Idempotency check**: Will running twice produce the same result?
- **Existing roles**: Search Galaxy and workspace for existing work

### 2. Structure the Code

Choose the right structure based on scope:

| Scope | Structure | When |
| ------- | ----------- | ------ |
| Quick task | Playbook (single file) | One-off automation |
| Reusable function | Role | Cross-project, parameterized |
| Related roles + plugins | Collection | Published/shared package |

See [role structure reference](./references/role-structure.md) for layout.

### 3. Write the Automation

**Playbook rules:**
- Use FQCNs: `ansible.builtin.copy`, not `copy`
- Name every task descriptively
- Use `block/rescue/always` for error handling
- Register results, use `changed_when`/`failed_when` for idempotency
- Avoid `command`/`shell` when a module exists
- Use `ansible.builtin.package` for cross-OS package installation

**Multi-OS patterns:**
- Use `ansible_os_family` or `ansible_distribution` for conditionals
- Prefer OS-specific variable files (`vars/RedHat.yml`, `vars/Debian.yml`)
- Use `ansible.windows.*` collection for Windows targets
- See [multi-OS patterns reference](./references/multi-os-patterns.md)

**Secrets:**
- Use `ansible-vault encrypt_string` for inline secrets
- Use SOPS-encrypted variable files with `community.sops.sops` lookup
- Never commit plaintext secrets

### 4. Lint the Code

```bash
# Ansible-lint with strict rules
ansible-lint playbook.yml --strict

# YAML lint
yamllint -c .yamllint.yml .
```

**Common lint fixes:**
- `fqcn[action-core]`: Use FQCN for builtin modules
- `name[missing]`: Add name to every task
- `risky-shell-pipe`: Use `pipefail` or switch to module
- `var-naming[no-role-prefix]`: Prefix role vars with role name

### 5. Test with Molecule

```bash
# Initialize Molecule scenario
molecule init scenario --driver-name docker

# Full test lifecycle
molecule test

# Develop iteratively
molecule converge  # Apply role
molecule verify    # Run assertions
molecule destroy   # Clean up
```

**Molecule drivers:**
| Driver | Best For |
| -------- | ---------- |
| Docker | Fast Linux testing |
| Podman | Rootless testing |
| Vagrant | Full VM testing (kernel, systemd) |
| Proxmox/vSphere | Production-like VMs |

### 6. Deploy

```bash
# Dry run (check mode)
ansible-playbook -i inventory/ playbook.yml --check --diff

# Apply
ansible-playbook -i inventory/ playbook.yml --diff

# Limit to specific hosts
ansible-playbook -i inventory/ playbook.yml --limit webservers
```

## Inventory Patterns

| Pattern | File | Use Case |
| --------- | ------ | ---------- |
| Static INI | `inventory/hosts.ini` | Small, stable environments |
| Static YAML | `inventory/hosts.yml` | Structured, version-controlled |
| Dynamic | `inventory/aws_ec2.yml` | Cloud auto-discovery |
| Constructed | `inventory/constructed.yml` | Derived groups from facts |

## Agent Integration

This skill works best with:
- **`executant-infra-architect`**: Review role/playbook design before implementation
- **`executant-security-ops`**: Validate hardening roles against CIS/ANSSI benchmarks
- **`executant-platform-ops`**: Target Proxmox/vCenter/XCP VMs with cloud-init post-provisioning
