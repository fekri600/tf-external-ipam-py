output "TRUST_ROLE_GITHUB" {
  description = "The ARN of the IAM role GitHub Actions can assume"
  value       = aws_iam_role.github_trust_role.arn
}

output "debug_state_bucket_name" {
  value = var.state_bucket_name
}
