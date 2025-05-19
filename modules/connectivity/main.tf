# =============================
# Connectivity Test via SSM
# =============================

# 1. Get EC2 private IPs via tag (for EC2s launched by ASG)
data "aws_instances" "asg_ec2s" {
  filter {
    name   = "tag:Name"
    values = ["${var.prefix}-${var.environment}-ec2"]
  }

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }

  depends_on = [module.environment] # ensure ASG and resources are ready
}

# 2. Create SSM Document for connectivity testing
resource "aws_ssm_document" "connectivity_test" {
  name          = "${var.prefix}-${var.environment}-connectivity-test"
  document_type = "Command"

  content = jsonencode({
    schemaVersion = "2.2",
    description   = "Connectivity testing to RDS, Redis, and EC2 peers",
    mainSteps = [{
      action = "aws:runShellScript",
      name   = "testConnectivity",
      inputs = {
        runCommand = [
          "echo '--- Testing RDS ---'",
          "nc -zv ${aws_db_instance.this.address} 3306 || echo 'RDS connection failed'",

          "echo '--- Testing Redis ---'",
          "nc -zv ${aws_elasticache_replication_group.redis.primary_endpoint_address} 6379 || echo 'Redis connection failed'",

          "echo '--- Testing EC2 Peers ---'",
%{ for ip in data.aws_instances.asg_ec2s.private_ips ~}
          "ping -c 2 ${ip} || echo 'Failed to ping ${ip}'",
%{ endfor ~}
        ]
      }
    }]
  })
}

# 3. Associate SSM document with EC2 instances by tag
resource "aws_ssm_association" "connectivity_run" {
  name = aws_ssm_document.connectivity_test.name

  targets = [{
    Key    = "tag:Name"
    Values = ["${var.prefix}-${var.environment}-ec2"]
  }]

  output_location {
    cloudwatch_logs {
      log_group_name = "/ssm/${var.prefix}/${var.environment}/connectivity"
    }
  }

  wait_for_success_timeout = "2m"
  depends_on = [aws_ssm_document.connectivity_test]
}
