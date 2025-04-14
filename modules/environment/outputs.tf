output "vpc_id" { value = aws_vpc.this.id }

output "app_instance_public_ip" { value = aws_instance.app.public_ip }