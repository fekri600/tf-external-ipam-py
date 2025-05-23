resource "aws_ssm_document" "connectivity_test" {
  name          = "${var.prefix}-${var.environment}-connectivity-test"
  document_type = "Command"

  content = jsonencode({
    schemaVersion = "2.2",
    description   = "Connectivity Test Script",
    mainSteps = [
      {
        action = "aws:runShellScript",
        name   = "testConnectivity",
        inputs = {
          runCommand = [
            "echo 'Testing RDS Port...' >> /var/log/application.log",
            "if nc -z ${var.rds_address} 3306; then echo '✅ RDS port 3306 is reachable' >> /var/log/application.log; else echo '❌ RDS port 3306 is NOT reachable' ; fi",

            "echo 'Testing Redis Port...' >> /var/log/application.log",
            "if nc -z ${var.redis_primary_endpoint} 6379; then echo '✅ Redis port 6379 is reachable' >> /var/log/application.log; else echo '❌ Redis port 6379 is NOT reachable' >> /var/log/application.log; fi",

            "echo 'Testing RDS IAM Authentication...' >> /var/log/application.log",
            "TOKEN=$(aws rds generate-db-auth-token --hostname ${var.rds_address} --port 3306 --region ${var.aws_region} --username ${var.db_user})",
            "mariadb -h ${var.rds_address} -u ${var.db_user} --password=\\$TOKEN -e 'SELECT NOW();' >> /var/log/application.log 2>&1 || echo '❌ IAM RDS auth failed' >> /var/log/application.log",

            "echo 'Testing outbound internet connectivity...' >> /var/log/application.log",
            "if curl -s --head https://www.google.com | grep '200 OK' > /dev/null; then echo '✅ EC2 instance has internet access (curl to google.com succeeded)' >> /var/log/application.log; else echo '❌ EC2 instance does NOT have internet access (curl to google.com failed)' >> /var/log/application.log; fi"
          ]
        }
      }
    ]
  })
}


resource "null_resource" "run_connectivity_test" {
  depends_on = [aws_ssm_document.connectivity_test]

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<EOT
aws ssm send-command \
  --document-name "${aws_ssm_document.connectivity_test.name}" \
  --targets "Key=tag:Name,Values=${var.prefix}-${var.environment}-ec2" \
  --comment "Connectivity test for ${var.environment}" \
  --region ${var.aws_region} \
  --cloud-watch-output-config CloudWatchLogGroupName=${var.logs.group_paths.ssm_connectivity}-${var.environment},CloudWatchOutputEnabled=true
EOT
  }
}

