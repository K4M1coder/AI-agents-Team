#cloud-config
# Managed by Terraform — M2 Compute MVP cloud-init template

hostname: ${hostname}
manage_etc_hosts: true
timezone: ${timezone}

users:
  - name: ${cloud_init_user}
    groups: [sudo]
    shell: /bin/bash
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    lock_passwd: true
    ssh_authorized_keys:
      - ${ssh_public_key}

package_update: true
package_upgrade: true

packages:
  - curl
  - ca-certificates
  - gnupg
  - qemu-guest-agent
  - python3
  - python3-pip
%{ for pkg in additional_packages ~}
  - ${pkg}
%{ endfor ~}

ntp:
  enabled: true
  ntp_client: chrony
  servers:
    - ${ntp_server}

runcmd:
  - systemctl enable --now qemu-guest-agent
  - timedatectl set-timezone ${timezone}
  - echo "Cloud-init provisioning complete" > /var/log/cloud-init-complete.log

final_message: "Cloud-init completed for ${hostname} after $UPTIME seconds"
