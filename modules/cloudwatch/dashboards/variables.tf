# modules/cloudwatch/dashboards/variables.tf
variable "aws_region" { type = string }
variable "env_configs" { 
  type = map(object({ 
    asg_name = string
    rds_id = string
    redis_id = string 
  })) 
}
