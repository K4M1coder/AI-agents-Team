network_cidr = "10.30.0.0/16"

subnets = [
  { name = "mgmt-preprod", cidr = "10.30.10.0/24", tier = "management" },
  { name = "prod-preprod", cidr = "10.30.20.0/24", tier = "production" },
  { name = "dmz-preprod",  cidr = "10.30.30.0/24", tier = "dmz" }
]

tags = {
  application = "platform"
  environment = "preprod"
  owner       = "infra-team"
}
