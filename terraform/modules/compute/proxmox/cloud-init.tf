# -----------------------------------------------------------------------------
# Cloud-init user-data template rendering
# Used by proxmox_virtual_environment_file in main.tf
# This file exists for module clarity — the actual templatefile() call is in main.tf
# -----------------------------------------------------------------------------

# cloud-init.tf is intentionally minimal.
# The template rendering is performed inline within the
# proxmox_virtual_environment_file resource in main.tf using templatefile().
#
# Template source: templates/cloud-init.yaml.tpl
#
# Variables passed to the template:
#   - hostname           (var.vm_name)
#   - timezone           (var.timezone)
#   - ssh_public_key     (var.cloud_init_ssh_key)
#   - cloud_init_user    (var.cloud_init_user)
#   - ntp_server         (var.ntp_server)
#   - additional_packages (var.additional_packages)
