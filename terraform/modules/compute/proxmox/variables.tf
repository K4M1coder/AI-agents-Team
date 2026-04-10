variable "proxmox_endpoint" {
  description = "Proxmox VE API endpoint URL (e.g., https://pve01.infra.local:8006)"
  type        = string

  validation {
    condition     = can(regex("^https://", var.proxmox_endpoint))
    error_message = "Proxmox endpoint must start with https://."
  }
}

variable "api_token" {
  description = "Proxmox API token in format 'user@realm!tokenid=secret'"
  type        = string
  sensitive   = true
}

variable "insecure_skip_verify" {
  description = "Skip TLS certificate verification (use only in dev/lab)"
  type        = bool
  default     = false
}

variable "node_name" {
  description = "Target Proxmox node to deploy the VM on"
  type        = string
}

variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]{0,62}$", var.vm_name))
    error_message = "VM name must start with a letter, contain only alphanumeric and hyphens, max 63 chars."
  }
}

variable "template_id" {
  description = "Proxmox VM ID of the golden image template to clone"
  type        = number
}

variable "cpu_cores" {
  description = "Number of CPU cores allocated to the VM"
  type        = number
  default     = 2

  validation {
    condition     = var.cpu_cores >= 1 && var.cpu_cores <= 128
    error_message = "CPU cores must be between 1 and 128."
  }
}

variable "memory_mb" {
  description = "Amount of RAM in megabytes allocated to the VM"
  type        = number
  default     = 2048

  validation {
    condition     = var.memory_mb >= 512 && var.memory_mb <= 524288
    error_message = "Memory must be between 512 MB and 512 GB."
  }
}

variable "disk_size_gb" {
  description = "Primary disk size in gigabytes"
  type        = number
  default     = 32

  validation {
    condition     = var.disk_size_gb >= 8 && var.disk_size_gb <= 4096
    error_message = "Disk size must be between 8 GB and 4 TB."
  }
}

variable "disk_datastore" {
  description = "Proxmox datastore ID for VM disks"
  type        = string
  default     = "local-lvm"
}

variable "snippets_datastore" {
  description = "Proxmox datastore ID for cloud-init snippets (must support 'snippets' content type)"
  type        = string
  default     = "local"
}

variable "vlan_tag" {
  description = "VLAN tag for the VM network interface"
  type        = number

  validation {
    condition     = var.vlan_tag >= 1 && var.vlan_tag <= 4094
    error_message = "VLAN tag must be between 1 and 4094."
  }
}

variable "network_bridge" {
  description = "Proxmox network bridge to attach the VM to"
  type        = string
  default     = "vmbr0"
}

variable "cloud_init_user" {
  description = "Default user created by cloud-init"
  type        = string
  default     = "deploy"
}

variable "cloud_init_ssh_key" {
  description = "SSH public key injected via cloud-init for the default user"
  type        = string
  sensitive   = true
}

variable "target_network" {
  description = "Logical network name (mgmt, prod, dmz) for documentation and tagging"
  type        = string
  default     = "prod"
}

variable "vm_ip_address" {
  description = "Static IP with CIDR for the VM (leave empty for DHCP)"
  type        = string
  default     = ""
}

variable "vm_gateway" {
  description = "Default gateway IP (leave empty for DHCP)"
  type        = string
  default     = ""
}

variable "dns_servers" {
  description = "List of DNS server IPs for the VM"
  type        = list(string)
  default     = ["10.20.10.2"]
}

variable "dns_domain" {
  description = "DNS search domain for the VM"
  type        = string
  default     = "infra.local"
}

variable "timezone" {
  description = "Timezone for the VM (IANA format)"
  type        = string
  default     = "Europe/Paris"
}

variable "ntp_server" {
  description = "Internal NTP/chrony server address"
  type        = string
  default     = "10.20.10.1"
}

variable "vm_tags" {
  description = "Tags to apply to the VM in Proxmox"
  type        = list(string)
  default     = ["terraform", "m2"]
}

variable "additional_packages" {
  description = "Extra packages to install via cloud-init"
  type        = list(string)
  default     = []
}
