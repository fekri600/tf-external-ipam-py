# modules/cloudwatch/alarms/variables.tf
variable "aws_region"  { type = string }
variable "alert_email" { type = string }
variable "env_configs" { type = map(object({ ec2_id=string, rds_id=string, redis_id=string })) }
