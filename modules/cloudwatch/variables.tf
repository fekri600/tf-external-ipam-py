# modules/cloudwatch/variables.tf
variable "aws_region" { type = string }
variable "alert_email" { type = string }
variable "env_configs" { 
  type = map(object({ 
    asg_name = string
    rds_id = string
    redis_id = string 
  })) 
}
variable "vpc_id" { type = string }
