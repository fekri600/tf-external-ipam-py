# modules/cloudwatch/dashboards/variables.tf
variable "aws_region"  { type = string }
variable "env_configs" { type = map(object({ ec2_id=string, rds_id=string, redis_id=string })) }
