# modules/environment/variables.tf
variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "prefix" {
  description = "The prefix to use for resource names"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "security_group_id" {
  description = "The ID of the EC2 security group to use"
  type        = string
}

variable "redis_security_group_id" {
  description = "The ID of the Redis security group to use"
  type        = string
}

variable "instance_type" {
  description = "The EC2 instance type"
  type        = string
}

variable "target_group_arn" {
  description = "The ARN of the target group"
  type        = string
}

variable "arch" {
  description = "The architecture type (e.g., x86_64)"
  type        = string
}

variable "db_engine" {
  description = "The database engine to use (e.g., mysql, postgres)"
  type        = string
}

variable "db_instance_class" {
  description = "The RDS instance class"
  type        = string
}

variable "db_storage" {
  description = "The initial storage size in GB for RDS instance"
  type        = number
}

variable "db_username" {
  description = "The master username for RDS instance"
  type        = string
}

variable "db_password" {
  description = "The master password for RDS instance"
  type        = string
}

variable "db_delete_snapshot" {
  description = "Whether to skip creating a final snapshot when destroying the RDS instance"
  type        = bool
}

variable "db_security_group_ids" {
  description = "List of security group IDs for RDS instance"
  type        = list(string)
}

variable "db_multi_az" {
  description = "Whether to enable multi-AZ deployment for RDS instance"
  type        = bool
}

variable "db_iam_authentication" {
  description = "Whether to enable IAM database authentication for RDS instance"
  type        = bool
}

variable "rds_subnet_group_name" {
  description = "The name of the RDS subnet group"
  type        = string
}

variable "redis_subnet_group_name" {
  description = "The name of the Redis subnet group"
  type        = string
}

variable "redis_node_type" {
  description = "The ElastiCache node type"
  type        = string
}