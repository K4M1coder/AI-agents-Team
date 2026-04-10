# Ubuntu 24.04 LTS Golden Image — Proxmox Builder
# Ref: M2 Virtualisation MVP

packer {
  required_version = ">= 1.10.0"

  required_plugins {
    proxmox = {
      version = ">= 1.1.8"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

variable "proxmox_url" {
  type        = string
  description = "Proxmox API URL (e.g., https://pve01.infra.local:8006/api2/json)"
}

variable "proxmox_token" {
  type        = string
  description = "Proxmox API token (user@realm!tokenid=secret)"
  sensitive   = true
}

variable "proxmox_node" {
  type        = string
  description = "Target Proxmox node name"
  default     = "pve01"
}

variable "vm_id" {
  type        = number
  description = "Proxmox VM ID for the template"
  default     = 9000
}

variable "iso_url" {
  type        = string
  description = "URL to the Ubuntu 24.04 ISO"
  default     = "https://releases.ubuntu.com/24.04/ubuntu-24.04-live-server-amd64.iso"
}

variable "iso_checksum" {
  type        = string
  description = "SHA256 checksum of the ISO"
  default     = ""
}

variable "iso_storage_pool" {
  type        = string
  description = "Proxmox storage pool for ISO files"
  default     = "local"
}

variable "disk_storage_pool" {
  type        = string
  description = "Proxmox storage pool for VM disks"
  default     = "local-lvm"
}

variable "disk_size" {
  type        = string
  description = "Disk size for the template"
  default     = "32G"
}

variable "memory" {
  type        = number
  description = "Memory in MB for the build VM"
  default     = 2048
}

variable "cores" {
  type        = number
  description = "CPU cores for the build VM"
  default     = 2
}

variable "ssh_username" {
  type        = string
  description = "SSH user for provisioning"
  default     = "deploy"
}

variable "ssh_password" {
  type        = string
  description = "SSH password for initial provisioning (replaced by cloud-init)"
  sensitive   = true
  default     = "packer-build"
}

source "proxmox-iso" "ubuntu-2404" {
  proxmox_url              = var.proxmox_url
  token                    = var.proxmox_token
  insecure_skip_tls_verify = true
  node                     = var.proxmox_node

  vm_id                = var.vm_id
  vm_name              = "tpl-ubuntu-2404"
  template_description = "Ubuntu 24.04 LTS Golden Image — Built by Packer"

  iso_url          = var.iso_url
  iso_checksum     = var.iso_checksum
  iso_storage_pool = var.iso_storage_pool
  unmount_iso      = true

  os       = "l26"
  cores    = var.cores
  memory   = var.memory
  sockets  = 1
  cpu_type = "x86-64-v2-AES"

  scsi_controller = "virtio-scsi-single"

  disks {
    disk_size    = var.disk_size
    storage_pool = var.disk_storage_pool
    type         = "scsi"
    format       = "raw"
    io_thread    = true
    discard      = true
  }

  network_adapters {
    model  = "virtio"
    bridge = "vmbr0"
  }

  cloud_init              = true
  cloud_init_storage_pool = var.disk_storage_pool

  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_timeout  = "20m"

  boot_command = [
    "<esc><wait>",
    "e<wait>",
    "<down><down><down><end>",
    " autoinstall ds=nocloud;",
    "<F10>"
  ]

  tags = "template;ubuntu;2404;packer"
}

build {
  name    = "ubuntu-2404"
  sources = ["source.proxmox-iso.ubuntu-2404"]

  # Wait for cloud-init to complete
  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 5; done"
    ]
  }

  # System update and base packages
  provisioner "shell" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get upgrade -y",
      "sudo apt-get install -y curl ca-certificates gnupg qemu-guest-agent python3 python3-pip net-tools",
      "sudo systemctl enable qemu-guest-agent"
    ]
  }

  # Install Trivy for security scanning
  provisioner "shell" {
    inline = [
      "sudo apt-get install -y wget apt-transport-https gnupg",
      "wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null",
      "echo 'deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main' | sudo tee /etc/apt/sources.list.d/trivy.list",
      "sudo apt-get update && sudo apt-get install -y trivy"
    ]
  }

  # Cleanup for template
  provisioner "shell" {
    inline = [
      "sudo cloud-init clean --logs",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo rm -f /var/lib/dbus/machine-id",
      "sudo apt-get autoremove -y",
      "sudo apt-get clean",
      "sudo rm -rf /tmp/* /var/tmp/*",
      "sudo sync"
    ]
  }
}
