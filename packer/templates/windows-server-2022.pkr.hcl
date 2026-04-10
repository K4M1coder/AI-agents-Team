# Windows Server 2022 Golden Image — Proxmox Builder
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
  default     = 9002
}

variable "iso_url" {
  type        = string
  description = "URL or path to the Windows Server 2022 ISO"
  default     = "local:iso/windows-server-2022.iso"
}

variable "iso_checksum" {
  type        = string
  description = "SHA256 checksum of the ISO"
  default     = ""
}

variable "virtio_iso_url" {
  type        = string
  description = "URL or path to the VirtIO drivers ISO for Windows"
  default     = "local:iso/virtio-win.iso"
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
  default     = "60G"
}

variable "memory" {
  type        = number
  description = "Memory in MB for the build VM"
  default     = 4096
}

variable "cores" {
  type        = number
  description = "CPU cores for the build VM"
  default     = 4
}

variable "winrm_username" {
  type        = string
  description = "WinRM user for provisioning"
  default     = "Administrator"
}

variable "winrm_password" {
  type        = string
  description = "WinRM password for provisioning"
  sensitive   = true
  default     = "Packer-Build!2024"
}

source "proxmox-iso" "windows-server-2022" {
  proxmox_url              = var.proxmox_url
  token                    = var.proxmox_token
  insecure_skip_tls_verify = true
  node                     = var.proxmox_node

  vm_id                = var.vm_id
  vm_name              = "tpl-win2022"
  template_description = "Windows Server 2022 Golden Image — Built by Packer"

  iso_file = var.iso_url
  unmount_iso = true

  additional_iso_files {
    device           = "sata1"
    iso_file         = var.virtio_iso_url
    unmount          = true
    iso_checksum     = "none"
  }

  os       = "win11"
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

  # WinRM communicator for Windows provisioning
  communicator   = "winrm"
  winrm_username = var.winrm_username
  winrm_password = var.winrm_password
  winrm_timeout  = "60m"
  winrm_insecure = true

  tags = "template;windows;2022;packer"
}

build {
  name    = "windows-server-2022"
  sources = ["source.proxmox-iso.windows-server-2022"]

  # Enable RDP
  provisioner "powershell" {
    inline = [
      "Set-ItemProperty -Path 'HKLM:\\System\\CurrentControlSet\\Control\\Terminal Server' -Name 'fDenyTSConnections' -Value 0",
      "Enable-NetFirewallRule -DisplayGroup 'Remote Desktop'",
      "Set-ItemProperty -Path 'HKLM:\\System\\CurrentControlSet\\Control\\Terminal Server\\WinStations\\RDP-Tcp' -Name 'UserAuthentication' -Value 1"
    ]
  }

  # Install Windows Updates
  provisioner "powershell" {
    inline = [
      "Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force",
      "Install-Module -Name PSWindowsUpdate -Force -Confirm:$false",
      "Import-Module PSWindowsUpdate",
      "Get-WindowsUpdate -AcceptAll -Install -IgnoreReboot"
    ]
  }

  # Install QEMU Guest Agent
  provisioner "powershell" {
    inline = [
      "$virtioPath = 'E:\\guest-agent\\qemu-ga-x86_64.msi'",
      "if (Test-Path $virtioPath) {",
      "  Start-Process msiexec.exe -ArgumentList '/i', $virtioPath, '/quiet', '/norestart' -Wait",
      "}"
    ]
  }

  # Basic hardening
  provisioner "powershell" {
    inline = [
      "# Disable SMBv1",
      "Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart",
      "# Enable Windows Firewall for all profiles",
      "Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True",
      "# Configure audit policy",
      "auditpol /set /category:\"Logon/Logoff\" /success:enable /failure:enable",
      "auditpol /set /category:\"Account Management\" /success:enable /failure:enable"
    ]
  }

  # Sysprep for template
  provisioner "powershell" {
    inline = [
      "# Clean up",
      "Remove-Item -Path $env:TEMP\\* -Recurse -Force -ErrorAction SilentlyContinue",
      "Clear-EventLog -LogName Application,System,Security -ErrorAction SilentlyContinue",
      "",
      "# Sysprep",
      "& \"$env:SystemRoot\\System32\\Sysprep\\Sysprep.exe\" /oobe /generalize /shutdown /quiet"
    ]
  }
}
