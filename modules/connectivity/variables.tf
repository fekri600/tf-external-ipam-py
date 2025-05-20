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
