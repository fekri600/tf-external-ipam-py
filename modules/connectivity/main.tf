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
              LOG_FILE="/var/log/connectivity_test.log"

              for i in {1..5}; do
                if [ -f "$LOG_FILE" ]; then break; fi
                echo "Waiting for $LOG_FILE to be available..."
                sleep 2
              done

              # Create or truncate the log file if needed (optional)
              > "$LOG_FILE"

              # Add a blank line for separation (useful between runs)
              echo "-------------------$(date '+%Y-%m-%d %H:%M:%S')-----------------------" >> "$LOG_FILE"

              # Add header with timestamp
              echo "== START CONNECTIVITY TEST == " >> "$LOG_FILE"


              echo "SSM Shell Environment Diagnostics:" >> "$LOG_FILE"
              echo "User: $(whoami)" >> "$LOG_FILE"
              echo "Home: $HOME" >> "$LOG_FILE"
              echo "MySQL Defaults:" >> "$LOG_FILE"
              mysql --print-defaults >> "$LOG_FILE" 2>&1

              echo "Testing RDS Port..." >> "$LOG_FILE"
              if nc -z ${var.rds_address} 3306; then
                echo "✅ RDS port 3306 is reachable" >> "$LOG_FILE"
              else
                echo "❌ RDS port 3306 is NOT reachable" >> "$LOG_FILE"
              fi

              echo "Testing Redis Port..." >> "$LOG_FILE"
              if nc -z ${var.redis_primary_endpoint} 6379; then
                echo "✅ Redis port 6379 is reachable" >> "$LOG_FILE"
              else
                echo "❌ Redis port 6379 is NOT reachable" >> "$LOG_FILE"
              fi

              echo "Ensuring IAM Auth Plugin is configured..." >> "$LOG_FILE"
              mysql --enable-cleartext-plugin \
                -h ${var.rds_address} \
                -u ${var.db_user} \
                --password="${var.database.password}" \
                -e "ALTER USER '${var.db_user}'@'%' IDENTIFIED WITH AWSAuthenticationPlugin AS 'RDS';" >> "$LOG_FILE" 2>&1

              echo "Generating RDS IAM Auth Token..." >> "$LOG_FILE"
              token=$(aws rds generate-db-auth-token \
                --hostname ${var.rds_address} \
                --port 3306 \
                --region ${var.aws_region} \
                --username ${var.db_user})

              echo "Testing IAM Authentication..." >> "$LOG_FILE"
              mysql --enable-cleartext-plugin \
                -h ${var.rds_address} \
                -u ${var.db_user} \
                --password="$token" \
                -e "SELECT NOW();" >> "$LOG_FILE" 2>&1

              if [ $? -eq 0 ]; then
                echo "✅ IAM RDS auth succeeded" >> "$LOG_FILE"
              else
                echo "❌ IAM RDS auth failed — is '${var.db_user}' IAM-enabled via AWSAuthenticationPlugin?" >> "$LOG_FILE"
              fi

              echo "Testing internet access..." >> "$LOG_FILE"
              if curl -s https://www.google.com > /dev/null; then
                echo "✅ EC2 instance has internet access" >> "$LOG_FILE"
              else
                echo "❌ No internet access" >> "$LOG_FILE"
              fi

              echo "== END CONNECTIVITY TEST ==" >> "$LOG_FILE"
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

