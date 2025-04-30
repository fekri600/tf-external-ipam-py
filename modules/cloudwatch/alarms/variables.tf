# modules/cloudwatch/alarms/variables.tf
variable "aws_region" {
  description = "The AWS region where resources will be created"
  type        = string
}

variable "alert_email" {
  description = "Email address to receive alarm notifications"
  type        = string
  default     = ""
}

variable "env_configs" {
  description = "Environment configurations containing resource IDs"
  type = map(object({
    asg_name = string
    rds_id   = string
    redis_id = string
  }))
}
