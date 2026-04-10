variable "network_cidr" {
  type        = string
  description = "Primary CIDR for environment"

  validation {
    condition     = can(cidrhost(var.network_cidr, 1))
    error_message = "network_cidr must be a valid CIDR."
  }
}

variable "subnets" {
  type = list(object({
    name = string
    cidr = string
    tier = string
  }))
  description = "Subnet list for environment"
  default     = []

  validation {
    condition = alltrue([
      for s in var.subnets : can(cidrhost(s.cidr, 1))
    ])
    error_message = "Each subnet cidr must be valid."
  }
}

variable "tags" {
  type        = map(string)
  description = "Common tags"
  default = {
    application = "platform"
    environment = "dev"
    owner       = "infra-team"
  }
}
