# Ansible Role Structure Reference

## Standard Role Layout

```text
roles/<role_name>/
├── defaults/
│   └── main.yml          # Default variables (lowest priority)
├── vars/
│   ├── main.yml          # Role variables (higher priority)
│   ├── RedHat.yml        # OS-family specific vars
│   ├── Debian.yml
│   └── Windows.yml
├── tasks/
│   ├── main.yml          # Entry point — includes OS-specific tasks
│   ├── install.yml       # Package installation
│   ├── configure.yml     # Configuration file management
│   ├── service.yml       # Service management
│   ├── RedHat.yml        # RHEL/AlmaLinux-specific tasks
│   ├── Debian.yml        # Debian/Ubuntu-specific tasks
│   └── Windows.yml       # Windows-specific tasks
├── handlers/
│   └── main.yml          # Service restart/reload handlers
├── templates/
│   └── config.j2         # Jinja2 templates
├── files/
│   └── static_file       # Static files to copy
├── meta/
│   └── main.yml          # Role metadata, dependencies, platforms
├── molecule/
│   └── default/
│       ├── molecule.yml  # Test configuration
│       ├── converge.yml  # Test playbook
│       └── verify.yml    # Assertions
├── README.md             # Role documentation
└── LICENSE
```

## Key Patterns

### OS-Family Dispatch (tasks/main.yml)

```yaml
---
- name: Include OS-specific variables
  ansible.builtin.include_vars:
    file: "{{ ansible_os_family }}.yml"
  when: ansible_os_family in ['RedHat', 'Debian']

- name: Include OS-specific tasks
  ansible.builtin.include_tasks:
    file: "{{ ansible_os_family }}.yml"
  when: ansible_os_family in ['RedHat', 'Debian']

- name: Include Windows tasks
  ansible.builtin.include_tasks:
    file: Windows.yml
  when: ansible_os_family == 'Windows'
```

### defaults/main.yml Example

```yaml
---
# Prefix all vars with role name to avoid conflicts
myapp_version: "1.0.0"
myapp_port: 8080
myapp_config_path: "/etc/myapp"
myapp_user: myapp
myapp_group: myapp
myapp_service_enabled: true
myapp_service_state: started
```

### meta/main.yml Example

```yaml
---
galaxy_info:
  author: team
  description: "Install and configure MyApp"
  license: MIT
  min_ansible_version: "2.15"
  platforms:
    - name: EL
      versions: [8, 9]
    - name: Ubuntu
      versions: [22.04, 24.04]
    - name: Debian
      versions: [11, 12]
    - name: Windows
      versions: [2019, 2022]

dependencies: []
```

### Handler Pattern

```yaml
---
# handlers/main.yml
- name: Restart myapp
  ansible.builtin.systemd:
    name: myapp
    state: restarted
    daemon_reload: true
  listen: "restart myapp"

- name: Reload myapp
  ansible.builtin.systemd:
    name: myapp
    state: reloaded
  listen: "reload myapp"
```

### Template with Validation

```yaml
- name: Deploy myapp configuration
  ansible.builtin.template:
    src: config.j2
    dest: "{{ myapp_config_path }}/config.yml"
    owner: "{{ myapp_user }}"
    group: "{{ myapp_group }}"
    mode: "0640"
    validate: "myapp validate --config %s"
  notify: restart myapp
```

## Collection Layout

```text
collections/ansible_collections/<namespace>/<collection>/
├── galaxy.yml           # Collection metadata
├── plugins/
│   ├── modules/         # Custom modules
│   ├── inventory/       # Inventory plugins
│   ├── lookup/          # Lookup plugins
│   ├── filter/          # Jinja2 filter plugins
│   └── callback/        # Callback plugins
├── roles/               # Bundled roles
├── playbooks/           # Bundled playbooks
├── docs/                # Documentation
├── tests/               # Integration tests
└── meta/
    └── runtime.yml      # Plugin routing & deprecations
```text
