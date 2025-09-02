# outputs.tf
output "vpc_id_1st_region" {
  value       = module.network_1st_region.vpc_id
  description = "VPC ID for the first region"
}

output "vpc_id_2nd_region" {
  value       = module.network_2nd_region.vpc_id
  description = "VPC ID for the second region"
}

output "az_1st_region" {
  value       = module.az_1st_region.az_names
  description = "AZ names for the first region"
}

output "az_2nd_region" {
  value       = module.az_2nd_region.az_names
  description = "AZ names for the second region"
}