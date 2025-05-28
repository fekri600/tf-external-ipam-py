# modules/backend_setup/outputs.tf


output "region" {
  value = module.backend_setup.region
}

output "bucket_name" {
  value = module.backend_setup.bucket_name
}

output "dynamodb_table_name" {
  value = module.backend_setup.dynamodb_table_name
}

output "TRUST_ROLE_GITHUB" {
  description = "The ARN of the IAM role GitHub Actions can assume"
  value       = module.oidc.TRUST_ROLE_GITHUB
}

output "debug_state_bucket_name" {
  value = module.oidc.debug_state_bucket_name
}
