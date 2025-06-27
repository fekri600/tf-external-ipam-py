# outputs.tf
output "vpc_id" {
  value       = module.network.vpc_id
  description = "VPC ID"
}

# output "log_group_names" {
#   value = module.cloudwatch.log_group_names
# }