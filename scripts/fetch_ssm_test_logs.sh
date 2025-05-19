#!/bin/bash

# ----------- CONFIG -------------
PREFIX="my-prefix"
ENVIRONMENT="staging"
REGION="us-east-1"
LOG_GROUP="/ssm/${PREFIX}/${ENVIRONMENT}/connectivity"
# --------------------------------

echo "Fetching EC2 instance IDs tagged with Name=${PREFIX}-${ENVIRONMENT}-ec2..."

INSTANCE_IDS=$(aws ec2 describe-instances \
  --region "$REGION" \
  --filters "Name=tag:Name,Values=${PREFIX}-${ENVIRONMENT}-ec2" \
            "Name=instance-state-name,Values=running" \
  --query "Reservations[].Instances[].InstanceId" \
  --output text)

echo "Found instances: $INSTANCE_IDS"
echo "Fetching log streams for log group: $LOG_GROUP"

for INSTANCE_ID in $INSTANCE_IDS; do
  echo "------ Logs for Instance: $INSTANCE_ID ------"

  LOG_STREAM_NAME=$(aws logs describe-log-streams \
    --region "$REGION" \
    --log-group-name "$LOG_GROUP" \
    --log-stream-name-prefix "$INSTANCE_ID" \
    --order-by "LastEventTime" \
    --descending \
    --limit 1 \
    --query "logStreams[0].logStreamName" \
    --output text)

  if [[ "$LOG_STREAM_NAME" == "None" ]]; then
    echo "No logs found for $INSTANCE_ID"
    continue
  fi

  aws logs get-log-events \
    --region "$REGION" \
    --log-group-name "$LOG_GROUP" \
    --log-stream-name "$LOG_STREAM_NAME" \
    --query "events[*].message" \
    --output text
  echo ""
done
