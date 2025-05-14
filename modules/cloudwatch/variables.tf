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


variable "logs" {
  description = "CloudWatch log configuration for all services"
  type = object({
    retention_in_days  = number
    log_group_prefix   = map(string)         
    group_paths        = map(string)
    filters = object({
      name = map(string)
      pattern = object({
        error  = string
        status = string
      })
      transformation = object({
        name      = map(string)
        namespace = string
        value     = string
      })
    })
  })
}




