output "github_trust_role_arn" {
  description = "The ARN of the IAM role GitHub Actions can assume"
  value       = aws_iam_role.github_trust_role.arn
}
