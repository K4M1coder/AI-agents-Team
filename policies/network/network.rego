package network

default deny = []

deny[msg] {
  some i
  subnet := input.subnets[i]
  not startswith(subnet.name, "mgmt-")
  not startswith(subnet.name, "prod-")
  not startswith(subnet.name, "dmz-")
  msg := sprintf("Subnet name '%s' must start with mgmt-/prod-/dmz-", [subnet.name])
}

deny[msg] {
  not startswith(input.network_cidr, "10.")
  not startswith(input.network_cidr, "172.")
  not startswith(input.network_cidr, "192.168.")
  msg := "network_cidr must be RFC1918 private range"
}
