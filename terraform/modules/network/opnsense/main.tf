terraform {
  required_version = ">= 1.6.0"

  required_providers {
    opnsense = {
      source  = "browningluke/opnsense"
      version = "~> 0.11"
    }
  }
}

# -----------------------------------------------------------------------------
# OPNsense Firewall Rules — M1 Network MVP
# Implements: MGMT→PROD allow, PROD→MGMT deny, DMZ inbound, default deny
# Ref: ADR-002 Network MVP Scope
# -----------------------------------------------------------------------------

provider "opnsense" {
  uri        = var.opnsense_url
  api_key    = var.api_key
  api_secret = var.api_secret
  insecure   = var.insecure_skip_verify
}

# --- MGMT → PROD: Allow SSH ---
resource "opnsense_firewall_filter" "mgmt_to_prod_ssh" {
  action    = "pass"
  direction = "in"
  protocol  = "TCP"

  source_net = var.mgmt_cidr
  destination_net = var.prod_cidr

  destination_port = "22"

  description = "MGMT to PROD - Allow SSH"
  sequence    = 10
  enabled     = true
}

# --- MGMT → PROD: Allow monitoring (Prometheus, node_exporter, Grafana) ---
resource "opnsense_firewall_filter" "mgmt_to_prod_monitoring" {
  action    = "pass"
  direction = "in"
  protocol  = "TCP"

  source_net      = var.mgmt_cidr
  destination_net = var.prod_cidr

  destination_port = "9090"

  description = "MGMT to PROD - Allow Prometheus (9090)"
  sequence    = 11
  enabled     = true
}

resource "opnsense_firewall_filter" "mgmt_to_prod_node_exporter" {
  action    = "pass"
  direction = "in"
  protocol  = "TCP"

  source_net      = var.mgmt_cidr
  destination_net = var.prod_cidr

  destination_port = "9100"

  description = "MGMT to PROD - Allow node_exporter (9100)"
  sequence    = 12
  enabled     = true
}

resource "opnsense_firewall_filter" "mgmt_to_prod_grafana" {
  action    = "pass"
  direction = "in"
  protocol  = "TCP"

  source_net      = var.mgmt_cidr
  destination_net = var.prod_cidr

  destination_port = "3000"

  description = "MGMT to PROD - Allow Grafana (3000)"
  sequence    = 13
  enabled     = true
}

# --- PROD → MGMT: Deny (explicit) ---
resource "opnsense_firewall_filter" "prod_to_mgmt_deny" {
  action    = "block"
  direction = "in"
  protocol  = "any"

  source_net      = var.prod_cidr
  destination_net = var.mgmt_cidr

  description = "PROD to MGMT - Deny all"
  sequence    = 20
  enabled     = true

  log = true
}

# --- DMZ Inbound: Allow HTTP ---
resource "opnsense_firewall_filter" "dmz_inbound_http" {
  action    = "pass"
  direction = "in"
  protocol  = "TCP"

  source_net      = "any"
  destination_net = var.dmz_cidr

  destination_port = "80"

  description = "DMZ Inbound - Allow HTTP"
  sequence    = 30
  enabled     = true
}

# --- DMZ Inbound: Allow HTTPS ---
resource "opnsense_firewall_filter" "dmz_inbound_https" {
  action    = "pass"
  direction = "in"
  protocol  = "TCP"

  source_net      = "any"
  destination_net = var.dmz_cidr

  destination_port = "443"

  description = "DMZ Inbound - Allow HTTPS"
  sequence    = 31
  enabled     = true
}

# --- Additional rules (dynamic) ---
resource "opnsense_firewall_filter" "additional_rules" {
  for_each = { for idx, rule in var.additional_rules : rule.description => rule }

  action    = each.value.action
  direction = each.value.direction
  protocol  = each.value.protocol

  source_net      = each.value.source_net
  destination_net = each.value.destination_net

  destination_port = each.value.destination_port

  description = each.value.description
  sequence    = 100 + index(var.additional_rules, each.value)
  enabled     = lookup(each.value, "enabled", true)

  log = lookup(each.value, "log", false)
}

# --- Default Deny ---
resource "opnsense_firewall_filter" "default_deny" {
  action    = "block"
  direction = "in"
  protocol  = "any"

  source_net      = "any"
  destination_net = "any"

  description = "Default deny - drop all unmatched traffic"
  sequence    = 65535
  enabled     = true

  log = true
}
