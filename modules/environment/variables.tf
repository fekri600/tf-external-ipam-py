# modules/environment/variables.tf

variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "prefix" {
  description = "The prefix to use for resource names"
  type        = string
}

variable "policies_path" {
  description = "Base path to IAM policy JSON files"
  type        = string
}
variable "scripts_path" {
  description = "base path to scripts files"
  type = string
  
}


variable "launch_template" {
  description = "Launch template configuration"
  type = object({
    architecture   = string
    storage        = string
    instance_type  = string
  })
}

variable "autoscaling" {
  description = "EC2 instance type and auto scaling group settings"
  type = object({
    desired_capacity          = number
    max_size                  = number
    min_size                  = number
    health_check_type         = string
    health_check_grace_period = number
    version                   = string
    propagate_at_launch       = bool
  })
}
variable "database" {
  description = "RDS instance settings for staging and production"
  type = object({
    engine                   = string
    instance_class           = string
    initial_storage          = number
    username                 = string
    password                 = string
    delete_automated_backup = bool
    iam_authentication      = bool
    multi_az                = bool
    backup_retention_period = number
    backup_window           = string
  })
  sensitive = true
}

variable "redis" {
  description = "ElastiCache Redis configuration"
  type = object({
    node_type = string
    redis_settings = object({
      engine             = string
      num_cache_clusters = number
    })
  })
}



variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "ec2_security_group_id" {
  description = "The ID of the EC2 security group to use"
  type        = string
}

variable "redis_security_group_id" {
  description = "The ID of the Redis security group to use"
  type        = string
}



variable "target_group_arn" {
  description = "The ARN of the target group"
  type        = string
}



variable "db_security_group_ids" {
  description = "List of security group IDs for RDS instance"
  type        = list(string)
}




variable "rds_subnet_group_name" {
  description = "The name of the RDS subnet group"
  type        = string
}

variable "redis_subnet_group_name" {
  description = "The name of the Redis subnet group"
  type        = string
}

variable "security_groups" {
  description = "Security Groups configuration: ports and protocols"
  type = object({
    port = object({
      http  = number
      https = number
      mysql = number
      redis = number
      any   = number
    })
    protocol = object({
      tcp = string
      any = string
    })
  })
}
variable "project_settings" {
  description = "Project and region configuration"
  type = object({
    project    = string
    aws_region = string
  })
}