output "ec2_private_ips" {
  description = "Private IPs of EC2 instances targeted by the connectivity test"
  value       = data.aws_instances.asg_ec2s.private_ips
}

output "ssm_document_name" {
  description = "The name of the SSM document used for connectivity testing"
  value       = aws_ssm_document.connectivity_test.name
}

output "ssm_association_id" {
  description = "The ID of the SSM association that executed the test"
  value       = aws_ssm_association.connectivity_run.id
}
