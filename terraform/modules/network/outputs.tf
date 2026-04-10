output "network_cidr" {
  value       = var.network_cidr
  description = "Network CIDR"
}

output "subnet_count" {
  value       = length(var.subnets)
  description = "Number of subnets"
}

output "tier_subnets" {
  value       = local.tier_subnets
  description = "Mapping of tier name to list of subnet names"
}

output "gateway_map" {
  value = {
    for name, detail in local.subnet_details : name => detail.gateway
  }
  description = "Mapping of subnet name to gateway IP"
}
