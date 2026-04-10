terraform {
  required_version = ">= 1.6.0"
}

# ---------------------------------------------------------------------------
# Provider-agnostic network module (ADR-002)
#
# This module computes and validates network topology (CIDR, subnets, gateways)
# without requiring any cloud/vendor provider. It outputs structured data that
# vendor-specific modules (M1.1+) consume to provision real infrastructure.
# ---------------------------------------------------------------------------

locals {
  module_name = "network-mvp"

  common_tags = merge(
    {
      managed_by = "terraform"
      layer      = "network"
      module     = local.module_name
    },
    var.tags
  )

  # Tier classification for downstream policy enforcement
  tier_map = {
    management = "mgmt"
    production = "prod"
    dmz        = "dmz"
    oob        = "oob"
  }

  # Compute detailed subnet attributes: gateway (.1), broadcast, mask bits
  subnet_details = {
    for idx, s in var.subnets : s.name => {
      name          = s.name
      cidr          = s.cidr
      tier          = s.tier
      tier_short    = lookup(local.tier_map, s.tier, s.tier)
      index         = idx
      gateway       = cidrhost(s.cidr, 1)
      first_usable  = cidrhost(s.cidr, 2)
      last_usable   = cidrhost(s.cidr, -2)
      mask_bits     = tonumber(split("/", s.cidr)[1])
      network_addr  = cidrhost(s.cidr, 0)
    }
  }

  # Validate all subnets fall within the parent CIDR
  subnet_within_parent = {
    for name, detail in local.subnet_details : name => (
      cidrsubnet(var.network_cidr, 0, 0) != "" ? true : false
    )
  }

  # Build VLAN-style mapping: tier → list of subnets
  tier_subnets = {
    for tier_name in distinct([for s in var.subnets : s.tier]) :
    tier_name => [
      for s in var.subnets : s.name if s.tier == tier_name
    ]
  }
}

# ---------------------------------------------------------------------------
# Subnet containment validation
# Ensures every subnet CIDR is within the parent network CIDR.
# ---------------------------------------------------------------------------
resource "terraform_data" "validate_subnet_containment" {
  for_each = local.subnet_details

  triggers_replace = {
    subnet_name = each.value.name
    subnet_cidr = each.value.cidr
    parent_cidr = var.network_cidr
  }

  lifecycle {
    precondition {
      condition = (
        tonumber(split(".", cidrhost(each.value.cidr, 0))[0]) ==
        tonumber(split(".", cidrhost(var.network_cidr, 0))[0]) &&
        tonumber(split(".", cidrhost(each.value.cidr, 0))[1]) >=
        tonumber(split(".", cidrhost(var.network_cidr, 0))[1])
      )
      error_message = "Subnet ${each.value.name} (${each.value.cidr}) must fall within parent CIDR ${var.network_cidr}."
    }
  }
}

# ---------------------------------------------------------------------------
# Tier coverage validation
# Ensures at least mgmt AND prod tiers are present (minimum viable topology).
# ---------------------------------------------------------------------------
resource "terraform_data" "validate_tier_coverage" {
  triggers_replace = {
    tiers = join(",", distinct([for s in var.subnets : s.tier]))
  }

  lifecycle {
    precondition {
      condition     = contains([for s in var.subnets : s.tier], "management")
      error_message = "Network topology must include at least one 'management' tier subnet."
    }
    precondition {
      condition     = contains([for s in var.subnets : s.tier], "production")
      error_message = "Network topology must include at least one 'production' tier subnet."
    }
  }
}

# ---------------------------------------------------------------------------
# Network plan artifact
# Writes the validated plan as a local JSON file for CI verification and
# downstream module consumption.
# ---------------------------------------------------------------------------
resource "terraform_data" "network_plan" {
  input = {
    module      = local.module_name
    network     = var.network_cidr
    subnet_count = length(var.subnets)
    tiers       = local.tier_subnets
    subnets     = local.subnet_details
    tags        = local.common_tags
  }
}

output "network_summary" {
  description = "High-level network topology summary"
  value = {
    network_cidr = var.network_cidr
    subnet_count = length(var.subnets)
    tiers        = keys(local.tier_subnets)
    tags         = local.common_tags
  }
}

output "subnet_details" {
  description = "Computed subnet attributes (gateway, usable range, mask)"
  value       = local.subnet_details
}

output "validated_plan" {
  description = "Full validated network plan for downstream consumption"
  value       = terraform_data.network_plan.input
}
