terraform {
  required_version = ">= 1.6.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.66"
    }
  }
}

# -----------------------------------------------------------------------------
# Proxmox VM — M2 Compute MVP
# Provisions a single VM from a golden image template with cloud-init
# -----------------------------------------------------------------------------

provider "proxmox" {
  endpoint = var.proxmox_endpoint
  api_token = var.api_token
  insecure  = var.insecure_skip_verify

  ssh {
    agent = true
  }
}

resource "proxmox_virtual_environment_file" "cloud_init_user_data" {
  content_type = "snippets"
  datastore_id = var.snippets_datastore
  node_name    = var.node_name

  source_raw {
    data = templatefile("${path.module}/templates/cloud-init.yaml.tpl", {
      hostname         = var.vm_name
      timezone         = var.timezone
      ssh_public_key   = var.cloud_init_ssh_key
      cloud_init_user  = var.cloud_init_user
      ntp_server       = var.ntp_server
      additional_packages = var.additional_packages
    })
    file_name = "${var.vm_name}-cloud-init.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "vm" {
  name      = var.vm_name
  node_name = var.node_name

  description = "Managed by Terraform — M2 Compute MVP"
  tags        = var.vm_tags

  # Clone from golden image template
  clone {
    vm_id = var.template_id
    full  = true
  }

  # CPU configuration
  cpu {
    cores   = var.cpu_cores
    sockets = 1
    type    = "x86-64-v2-AES"
  }

  # Memory configuration
  memory {
    dedicated = var.memory_mb
  }

  # Primary disk
  disk {
    datastore_id = var.disk_datastore
    interface    = "scsi0"
    size         = var.disk_size_gb
    file_format  = "raw"
    iothread     = true
    discard      = "on"
  }

  # Network interface on specified VLAN
  network_device {
    bridge  = var.network_bridge
    vlan_id = var.vlan_tag
    model   = "virtio"
  }

  # Cloud-init drive
  initialization {
    datastore_id = var.disk_datastore
    interface    = "ide2"

    user_data_file_id = proxmox_virtual_environment_file.cloud_init_user_data.id

    ip_config {
      ipv4 {
        address = var.vm_ip_address != "" ? var.vm_ip_address : "dhcp"
        gateway = var.vm_gateway != "" ? var.vm_gateway : null
      }
    }

    dns {
      servers = var.dns_servers
      domain  = var.dns_domain
    }
  }

  # Ensure VM starts after creation
  started = true

  # Wait for cloud-init to complete on first boot
  on_boot = true

  lifecycle {
    ignore_changes = [
      initialization[0].user_data_file_id,
    ]
  }
}
