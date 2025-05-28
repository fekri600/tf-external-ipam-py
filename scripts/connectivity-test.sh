#!/bin/bash

LOG_FILE="/var/log/connectivity_test.log"

for i in {1..5}; do
  if [ -f "$LOG_FILE" ]; then break; fi
  echo "Waiting for $LOG_FILE to be available..."
  sleep 2
done

# Truncate or create the file
> "$LOG_FILE"

echo "-------------------$(date '+%Y-%m-%d %H:%M:%S')-----------------------" >> "$LOG_FILE"
echo "== START CONNECTIVITY TEST ==" >> "$LOG_FILE"

echo "SSM Shell Environment Diagnostics:" >> "$LOG_FILE"
echo "User: $(whoami)" >> "$LOG_FILE"
echo "Home: $HOME" >> "$LOG_FILE"
echo "MySQL Defaults:" >> "$LOG_FILE"
mysql --print-defaults >> "$LOG_FILE" 2>&1

echo "Testing RDS Port..." >> "$LOG_FILE"
if nc -z ${rds_address} 3306; then
  echo "✅ RDS port 3306 is reachable" >> "$LOG_FILE"
else
  echo "❌ RDS port 3306 is NOT reachable" >> "$LOG_FILE"
fi

echo "Testing Redis Port..." >> "$LOG_FILE"
if nc -z ${redis_primary_endpoint} 6379; then
  echo "✅ Redis port 6379 is reachable" >> "$LOG_FILE"
else
  echo "❌ Redis port 6379 is NOT reachable" >> "$LOG_FILE"
fi

echo "Ensuring IAM Auth Plugin is configured..." >> "$LOG_FILE"
mysql --enable-cleartext-plugin \
  -h ${rds_address} \
  -u ${db_user} \
  --password="${database_password}" \
  -e "ALTER USER '${db_user}'@'%' IDENTIFIED WITH AWSAuthenticationPlugin AS 'RDS';" >> "$LOG_FILE" 2>&1

echo "Generating RDS IAM Auth Token..." >> "$LOG_FILE"
token=$(aws rds generate-db-auth-token \
  --hostname ${rds_address} \
  --port 3306 \
  --region ${aws_region} \
  --username ${db_user})

echo "Testing IAM Authentication..." >> "$LOG_FILE"
mysql --enable-cleartext-plugin \
  -h ${rds_address} \
  -u ${db_user} \
  --password="$token" \
  -e "SELECT NOW();" >> "$LOG_FILE" 2>&1

if [ $? -eq 0 ]; then
  echo "✅ IAM RDS auth succeeded" >> "$LOG_FILE"
else
  echo "❌ IAM RDS auth failed — is '${db_user}' IAM-enabled via AWSAuthenticationPlugin?" >> "$LOG_FILE"
fi

echo "Testing internet access..." >> "$LOG_FILE"
if curl -s https://www.google.com > /dev/null; then
  echo "✅ EC2 instance has internet access" >> "$LOG_FILE"
else
  echo "❌ No internet access" >> "$LOG_FILE"
fi

echo "== END CONNECTIVITY TEST ==" >> "$LOG_FILE"
