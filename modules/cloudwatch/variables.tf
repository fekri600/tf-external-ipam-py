variable "aws_region" { type = string }

variable "env_configs" {
  type = map(object({
    asg_name = string
    rds_id   = string
    redis_id = string
  }))
}
variable "vpc_id" { type = string }

variable "alarm" {
  description = "CloudWatch alarm configuration"
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
    alert_email = string
  })
}

variable "logs" {
  description = "CloudWatch log configuration for all services"
  type = object({
    retention_in_days = number
    group_paths       = map(string)
    filters = object({
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

variable "dashboard_config" {
  description = "Configuration for CloudWatch dashboards"
  type = object({
    create_combined_dashboard  = bool
    create_separate_dashboards = bool
  })
  default = {
    create_combined_dashboard  = true
    create_separate_dashboards = false
  }
}

variable "environment" { type = string }


