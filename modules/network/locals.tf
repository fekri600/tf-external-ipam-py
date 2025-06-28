

locals {
  vpc_cidr = data.external.ipam_vpc.result["cidr"]
  publics  = split(",", data.external.ipam.result.public_subnets)
  privates = split(",", data.external.ipam.result.private_subnets)
}
