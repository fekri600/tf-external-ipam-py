resource "aws_ssm_document" "connectivity_test" {
  name          = "${var.prefix}-${var.environment}-connectivity-test"
  document_type = "Command"

  content = jsonencode({
    schemaVersion = "2.2"
    description   = "Connectivity Test Script"
    mainSteps = [
      {
        action = "aws:runShellScript"
        name   = "testConnectivity"
        inputs = {
          runCommand = [
            "echo 'Testing RDS Port...'",
            "nc -zv ${var.rds_address} 3306 || echo 'RDS port check failed'",

            "echo 'Testing Redis Port...'",
            "nc -zv ${var.redis_primary_endpoint} 6379 || echo 'Redis port check failed'",

            "echo 'Testing Local Web Server...'",
            "curl -s -o /dev/null -w '%%{http_code}' http://localhost || echo 'Web server test failed'",

            "echo 'Testing RDS IAM Authentication...'",
            "TOKEN=$(aws rds generate-db-auth-token --hostname ${var.rds_address} --port 3306 --region ${var.aws_region} --username ${var.db_user})",
            "mysql --host=${var.rds_address} --port=3306 --enable-cleartext-plugin --user=${var.db_user} --password=\"$TOKEN\" -e 'SELECT NOW();' || echo 'IAM RDS auth failed'"
          ]
        }
      }
    ]
  })
}

resource "null_resource" "run_connectivity_test" {
  depends_on = [
    aws_ssm_document.connectivity_test
  ]

  provisioner "local-exec" {
    command = <<EOT
aws ssm send-command \
  --document-name "${aws_ssm_document.connectivity_test.name}" \
  --targets "Key=tag:Name,Values=${var.ec2_name_tag}" \
  --comment "Connectivity test for ${var.environment}" \
  --region ${var.aws_region} \
  --cloud-watch-output-config '{"CloudWatchLogGroupName":"${var.logs.group_paths.ssm_connectivity}-${var.environment}","CloudWatchOutputEnabled":true}'
EOT
  }
}
