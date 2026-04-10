output "rule_ids" {
  description = "Map of firewall rule description to resource ID"
  value = merge(
    {
      "mgmt_to_prod_ssh"           = opnsense_firewall_filter.mgmt_to_prod_ssh.id
      "mgmt_to_prod_monitoring"    = opnsense_firewall_filter.mgmt_to_prod_monitoring.id
      "mgmt_to_prod_node_exporter" = opnsense_firewall_filter.mgmt_to_prod_node_exporter.id
      "mgmt_to_prod_grafana"       = opnsense_firewall_filter.mgmt_to_prod_grafana.id
      "prod_to_mgmt_deny"          = opnsense_firewall_filter.prod_to_mgmt_deny.id
      "dmz_inbound_http"           = opnsense_firewall_filter.dmz_inbound_http.id
      "dmz_inbound_https"          = opnsense_firewall_filter.dmz_inbound_https.id
      "default_deny"               = opnsense_firewall_filter.default_deny.id
    },
    { for k, v in opnsense_firewall_filter.additional_rules : k => v.id }
  )
}

output "rule_count" {
  description = "Total number of firewall rules managed by this module"
  value       = 8 + length(var.additional_rules)
}

output "applied_rules" {
  description = "Summary of all applied firewall rules"
  value = concat(
    [
      {
        name      = "mgmt_to_prod_ssh"
        action    = "pass"
        src       = var.mgmt_cidr
        dst       = var.prod_cidr
        dst_port  = "22"
        direction = "in"
      },
      {
        name      = "mgmt_to_prod_monitoring"
        action    = "pass"
        src       = var.mgmt_cidr
        dst       = var.prod_cidr
        dst_port  = "9090"
        direction = "in"
      },
      {
        name      = "mgmt_to_prod_node_exporter"
        action    = "pass"
        src       = var.mgmt_cidr
        dst       = var.prod_cidr
        dst_port  = "9100"
        direction = "in"
      },
      {
        name      = "mgmt_to_prod_grafana"
        action    = "pass"
        src       = var.mgmt_cidr
        dst       = var.prod_cidr
        dst_port  = "3000"
        direction = "in"
      },
      {
        name      = "prod_to_mgmt_deny"
        action    = "block"
        src       = var.prod_cidr
        dst       = var.mgmt_cidr
        dst_port  = "any"
        direction = "in"
      },
      {
        name      = "dmz_inbound_http"
        action    = "pass"
        src       = "any"
        dst       = var.dmz_cidr
        dst_port  = "80"
        direction = "in"
      },
      {
        name      = "dmz_inbound_https"
        action    = "pass"
        src       = "any"
        dst       = var.dmz_cidr
        dst_port  = "443"
        direction = "in"
      },
      {
        name      = "default_deny"
        action    = "block"
        src       = "any"
        dst       = "any"
        dst_port  = "any"
        direction = "in"
      },
    ],
    [for rule in var.additional_rules : {
      name      = rule.description
      action    = rule.action
      src       = rule.source_net
      dst       = rule.destination_net
      dst_port  = rule.destination_port
      direction = rule.direction
    }]
  )
}
