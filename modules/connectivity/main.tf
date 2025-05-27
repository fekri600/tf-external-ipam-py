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
            <<-EOT
              LOG_FILE="/var/log/application.log"
              for i in {1..5}; do
                if [ -f "$LOG_FILE" ]; then break; fi
                echo "Waiting for $LOG_FILE to be available..."
                sleep 2
              done
              [ -f "$LOG_FILE" ] || LOG_FILE="/tmp/connectivity_test.log"
              touch $LOG_FILE

              echo "== START CONNECTIVITY TEST ==" >> $LOG_FILE

              echo "Testing RDS Port..." >> $LOG_FILE
              if nc -z ${var.rds_address} 3306; then
                echo "✅ RDS port 3306 is reachable" >> $LOG_FILE
              else
                echo "❌ RDS port 3306 is NOT reachable" >> $LOG_FILE
              fi

              echo "Testing Redis Port..." >> $LOG_FILE
              if nc -z ${var.redis_primary_endpoint} 6379; then
                echo "✅ Redis port 6379 is reachable" >> $LOG_FILE
              else
                echo "❌ Redis port 6379 is NOT reachable" >> $LOG_FILE
              fi

              echo "Testing RDS IAM Authentication..." >> $LOG_FILE
              token=$(aws rds generate-db-auth-token \
                --hostname ${var.rds_address} \
                --port 3306 \
                --region ${var.aws_region} \
                --username ${var.db_user})

              mariadb -h ${var.rds_address} -u ${var.db_user} --password="$token" \
                -e "SELECT NOW();" >> $LOG_FILE 2>&1 || \
                echo "❌ IAM RDS auth failed" >> $LOG_FILE

              echo "Testing internet access..." >> $LOG_FILE
              if curl -s --head https://www.google.com | grep "200 OK" > /dev/null; then
                echo "✅ EC2 instance has internet access" >> $LOG_FILE
              else
                echo "❌ No internet access" >> $LOG_FILE
              fi

              echo "== END CONNECTIVITY TEST ==" >> $LOG_FILE
            EOT
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

