# variables.tf
variable "project" {
  description = "The name of the project"
  type        = string
}

variable "aws_region" {
  description = "The AWS region where resources will be created"
  type        = string
}

variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "public_subnets" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
}

variable "alert_email" {
  description = "Email address for receiving alerts"
  type        = string
}

variable "db_engine" {
  description = "The database engine to use (e.g., mysql, postgres)"
  type        = string
}

# Staging environment variables
variable "stag_instance_type" {
  description = "EC2 instance type for staging environment"
  type        = string
}

variable "stag_ami_id" { type = string }
variable "stag_db_instance_class" {
  description = "RDS instance class for staging environment"
  type        = string
}

variable "stag_db_init_storage" {
  description = "Initial storage size in GB for staging RDS instance"
  type        = number
}

variable "stag_db_username" {
  description = "Master username for staging RDS instance"
  type        = string
}

variable "stag_db_password" {
  description = "Master password for staging RDS instance"
  type        = string
}

variable "stag_db_delete_snapshot" {
  description = "Whether to skip creating a final snapshot when destroying the staging RDS instance"
  type        = bool
}

variable "stag_db_multi_az" {
  description = "Whether to enable multi-AZ deployment for staging RDS instance"
  type        = bool
}

variable "stag_db_iam_authentication" {
  description = "Whether to enable IAM database authentication for staging RDS instance"
  type        = bool
}

variable "stag_redis_node_type" {
  description = "ElastiCache node type for staging environment"
  type        = string
}

# Production environment variables
variable "prod_instance_type" {
  description = "EC2 instance type for production environment"
  type        = string
}

variable "prod_ami_id" { type = string }
variable "prod_db_instance_class" {
  description = "RDS instance class for production environment"
  type        = string
}

variable "prod_db_init_storage" {
  description = "Initial storage size in GB for production RDS instance"
  type        = number
}

variable "prod_db_username" {
  description = "Master username for production RDS instance"
  type        = string
}

variable "prod_db_password" {
  description = "Master password for production RDS instance"
  type        = string
}

variable "prod_db_delete_snapshot" {
  description = "Whether to skip creating a final snapshot when destroying the production RDS instance"
  type        = bool
}

variable "prod_db_multi_az" {
  description = "Whether to enable multi-AZ deployment for production RDS instance"
  type        = bool
}

variable "prod_db_iam_authentication" {
  description = "Whether to enable IAM database authentication for production RDS instance"
  type        = bool
}

variable "prod_redis_node_type" {
  description = "ElastiCache node type for production environment"
  type        = string
}
