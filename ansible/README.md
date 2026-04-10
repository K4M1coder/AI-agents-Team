# Ansible — Configuration Management

## Overview

Ansible playbooks and roles for host bootstrap, network service configuration, and compliance enforcement across Debian and RedHat families.

## Directory Structure

```
ansible/
├── playbooks/
│   └── bootstrap.yml           # Base host bootstrap (packages, chrony)
├── roles/
│   ├── network_dns/            # DNS server configuration (PowerDNS/bind)
│   │   ├── tasks/main.yml
│   │   ├── defaults/main.yml
│   │   ├── handlers/main.yml
│   │   └── templates/
│   ├── network_vlans/          # VLAN tagging configuration
│   │   ├── tasks/main.yml
│   │   ├── defaults/main.yml
│   │   └── templates/
│   └── network_ntp/            # NTP/chrony configuration
│       ├── tasks/main.yml
│       ├── defaults/main.yml
│       ├── handlers/main.yml
│       └── templates/
└── README.md
```

## Prerequisites

- Python 3.11+
- Ansible >= 2.16
- ansible-lint >= 24.x

```bash
pip install ansible ansible-lint
```

## Running Playbooks

```bash
# Bootstrap all hosts
ansible-playbook -i inventory ansible/playbooks/bootstrap.yml

# Dry-run (check mode)
ansible-playbook -i inventory ansible/playbooks/bootstrap.yml --check --diff

# Run specific role via tags
ansible-playbook -i inventory ansible/playbooks/bootstrap.yml --tags ntp
```

## Roles

| Role | Purpose | OS Support |
|------|---------|------------|
| `network_dns` | Install and configure DNS (PowerDNS or bind) | Debian, RedHat |
| `network_vlans` | Configure VLAN interfaces and tagging | Debian, RedHat |
| `network_ntp` | Configure chrony NTP synchronization | Debian, RedHat |

## Linting

```bash
ansible-lint ansible/playbooks/bootstrap.yml
ansible-lint ansible/roles/
```

## Conventions

- Roles use `ansible.builtin` FQCN for all modules
- Multi-OS via `ansible_os_family` conditionals
- See [naming conventions](../docs/conventions/naming.md)
