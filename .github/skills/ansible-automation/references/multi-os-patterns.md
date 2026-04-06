# Multi-OS Ansible Patterns Reference

## Package Management Across OS Families

### Universal Package Module

```yaml
# Works for dnf (RHEL) and apt (Debian) — NOT Windows
- name: Install common packages
  ansible.builtin.package:
    name: "{{ item }}"
    state: present
  loop: "{{ common_packages }}"
```

### OS-Specific Package Names

```yaml
# vars/RedHat.yml
common_packages:
  - python3
  - python3-pip
  - firewalld
  - policycoreutils-python-utils  # SELinux tools

# vars/Debian.yml
common_packages:
  - python3
  - python3-pip
  - ufw
  - apparmor-utils

# vars/Windows.yml (use win_chocolatey or win_package)
common_packages:
  - python3
  - git
```

### Windows Package Installation

```yaml
- name: Install packages via Chocolatey (Windows)
  chocolatey.chocolatey.win_chocolatey:
    name: "{{ item }}"
    state: present
  loop: "{{ common_packages }}"
  when: ansible_os_family == 'Windows'
```

## Service Management

### Linux (systemd)

```yaml
- name: Enable and start service
  ansible.builtin.systemd:
    name: "{{ service_name }}"
    state: started
    enabled: true
    daemon_reload: true
```

### Windows

```yaml
- name: Enable and start Windows service
  ansible.windows.win_service:
    name: "{{ service_name }}"
    start_mode: auto
    state: started
```

## Firewall Rules

### Firewalld (RHEL/AlmaLinux)

```yaml
- name: Open application port (firewalld)
  ansible.posix.firewalld:
    port: "{{ app_port }}/tcp"
    permanent: true
    state: enabled
    immediate: true
  when: ansible_os_family == 'RedHat'
```

### UFW (Ubuntu/Debian)

```yaml
- name: Open application port (UFW)
  community.general.ufw:
    rule: allow
    port: "{{ app_port }}"
    proto: tcp
  when: ansible_os_family == 'Debian'
```

### Windows Firewall

```yaml
- name: Open application port (Windows Firewall)
  community.windows.win_firewall_rule:
    name: "Allow App Port {{ app_port }}"
    localport: "{{ app_port }}"
    protocol: tcp
    direction: in
    action: allow
    state: present
    enabled: true
  when: ansible_os_family == 'Windows'
```

## User Management

### Linux User Management

```yaml
- name: Create service user (Linux)
  ansible.builtin.user:
    name: "{{ app_user }}"
    system: true
    shell: /sbin/nologin
    home: "{{ app_home }}"
    create_home: true
  when: ansible_os_family != 'Windows'
```

### Windows Users management

```yaml
- name: Create service user (Windows)
  ansible.windows.win_user:
    name: "{{ app_user }}"
    password: "{{ app_user_password }}"
    state: present
    groups:
      - Users
  when: ansible_os_family == 'Windows'
```

## SELinux (RHEL/AlmaLinux)

```yaml
- name: Set SELinux boolean for httpd
  ansible.posix.seboolean:
    name: httpd_can_network_connect
    state: true
    persistent: true

- name: Set SELinux file context
  community.general.sefcontext:
    target: "{{ app_home }}(/.*)?"
    setype: httpd_sys_content_t
    state: present
  notify: restorecon app home

# Handler
- name: Restorecon app home
  ansible.builtin.command:
    cmd: "restorecon -Rv {{ app_home }}"
  listen: "restorecon app home"
```

## Connection Methods

| OS Family | Connection | Variables |
| ----------- | ----------- | ----------- |
| Linux | SSH (default) | `ansible_user`, `ansible_ssh_private_key_file` |
| Windows | WinRM | `ansible_connection: winrm`, `ansible_winrm_transport: ntlm` |
| Windows (SSH) | SSH | `ansible_connection: ssh`, `ansible_shell_type: powershell` |
| Network devices | network_cli | `ansible_network_os`, `ansible_become_method: enable` |

### Windows WinRM Inventory Example

```yaml
windows:
  hosts:
    win-server-01:
      ansible_host: 192.168.1.100
  vars:
    ansible_connection: winrm
    ansible_winrm_transport: ntlm
    ansible_winrm_server_cert_validation: ignore
    ansible_user: Administrator
    ansible_password: "{{ vault_win_admin_password }}"
```

## Conditional Patterns

### Distribution-Level (most specific)

```yaml
- name: Install EPEL (AlmaLinux/RHEL only)
  ansible.builtin.dnf:
    name: epel-release
    state: present
  when: ansible_distribution in ['AlmaLinux', 'RedHat', 'CentOS', 'Rocky']
```

### Version-Level

```yaml
- name: Configure repo (Ubuntu 24.04+)
  ansible.builtin.template:
    src: sources_deb822.j2
    dest: /etc/apt/sources.list.d/myapp.sources
  when:
    - ansible_distribution == 'Ubuntu'
    - ansible_distribution_version is version('24.04', '>=')
```text
