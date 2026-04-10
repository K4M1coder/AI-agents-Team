variable "opnsense_url" {
  description = "URL of the OPNsense API endpoint (e.g., https://fw.infra.local/api)"
  type        = string

  validation {
    condition     = can(regex("^https://", var.opnsense_url))
    error_message = "OPNsense URL must start with https://."
  }
}

variable "api_key" {
  description = "OPNsense API key for authentication"
  type        = string
  sensitive   = true
}

variable "api_secret" {
  description = "OPNsense API secret for authentication"
  type        = string
  sensitive   = true
}

variable "insecure_skip_verify" {
  description = "Skip TLS certificate verification (use only in dev/lab)"
  type        = bool
  default     = false
}

variable "mgmt_cidr" {
  description = "CIDR block for the Management network (VLAN 10)"
  type        = string
  default     = "10.20.10.0/24"

  validation {
    condition     = can(cidrnetmask(var.mgmt_cidr))
    error_message = "mgmt_cidr must be a valid CIDR block."
  }
}

variable "prod_cidr" {
  description = "CIDR block for the Production network (VLAN 20)"
  type        = string
  default     = "10.20.20.0/24"

  validation {
    condition     = can(cidrnetmask(var.prod_cidr))
    error_message = "prod_cidr must be a valid CIDR block."
  }
}

variable "dmz_cidr" {
  description = "CIDR block for the DMZ network (VLAN 30)"
  type        = string
  default     = "10.20.30.0/24"

  validation {
    condition     = can(cidrnetmask(var.dmz_cidr))
    error_message = "dmz_cidr must be a valid CIDR block."
  }
}

variable "additional_rules" {
  description = "List of additional firewall rules to apply beyond the baseline"
  type = list(object({
    action           = string
    direction        = string
    protocol         = string
    source_net       = string
    destination_net  = string
    destination_port = string
    description      = string
    enabled          = optional(bool, true)
    log              = optional(bool, false)
  }))
  default = []
}
