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
            templatefile("${var.scripts_path}/connectivity-test.sh", {
              rds_address            = var.rds_address,
              redis_primary_endpoint = var.redis_primary_endpoint,
              db_user                = var.db_user,
              database_password      = var.database.password,
              aws_region             = var.aws_region
            })
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

