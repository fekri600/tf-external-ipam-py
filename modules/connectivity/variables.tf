variable "prefix" {
  description = "Prefix for naming resources"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., staging, production)"
  type        = string
}

variable "rds_address" {
  description = "RDS endpoint address"
  type        = string
}

variable "redis_primary_endpoint" {
  description = "Primary endpoint of the Redis cluster"
  type        = string
}

variable "ec2_name_tag" {
  description = "The Name tag of EC2 instances to target (launched by ASG)"
  type        = string
}
