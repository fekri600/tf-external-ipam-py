variable "prefix" {
  description = "Prefix for resource naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., staging, production)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "rds_address" {
  description = "RDS endpoint address"
  type        = string
}

variable "redis_primary_endpoint" {
  description = "Redis primary endpoint"
  type        = string
}

variable "ec2_name_tag" {
  description = "Name tag used to find EC2 instance for SSM test"
  type        = string
}

variable "db_user" {
  description = "Database username for IAM authentication test"
  type        = string
}
variable "logs" {
  description = "CloudWatch log configuration for all services"
  type = object({
    retention_in_days = number
    log_group_prefix  = map(string)
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

