network_cidr = "10.20.0.0/16"

subnets = [
  { name = "mgmt-dev", cidr = "10.20.10.0/24", tier = "management" },
  { name = "prod-dev", cidr = "10.20.20.0/24", tier = "production" },
  { name = "dmz-dev",  cidr = "10.20.30.0/24", tier = "dmz" }
]

tags = {
  application = "platform"
  environment = "dev"
  owner       = "infra-team"
}
