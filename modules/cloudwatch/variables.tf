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

variable "alarm" {
  type = object({
    namespace = map(string)
    metric    = map(string)
    threshold = map(number)
    dim       = map(string)
    attr      = map(string)
    common_settings = object({
      comparison_operator = string
      evaluation_periods  = number
      period              = number
      statistic           = string
    })
  })
}

