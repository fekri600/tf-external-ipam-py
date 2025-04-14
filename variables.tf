variable "region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "backend_bucket" {
  description = "S3 bucket for Terraform remote state."
  type        = string
}

variable "lock_table" {
  description = "DynamoDB table for Terraform state locking."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the application server."
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI to use for the EC2 instance (must support your OS)."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "List of CIDR blocks for public subnets."
  type        = list(string)
}

variable "private_subnets" {
  description = "List of CIDR blocks for private subnets."
  type        = list(string)
}

variable "availability_zones" {
  description = "List of AZs to use for the subnets."
  type        = list(string)
}

variable "db_engine" {
  description = "Database engine for the RDS instance (e.g., mysql, postgres)."
  type        = string
  default     = "mysql"
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "db_storage" {
  description = "Allocated storage for RDS (in GB)."
  type        = number
  default     = 20
}

variable "db_username" {
  description = "Username for the RDS instance."
  type        = string
}

variable "db_password" {
  description = "Password for the RDS instance."
  type        = string
  sensitive   = true
}

variable "db_parameter_group" {
  description = "Parameter group for the RDS instance."
  type        = string
  default     = "default.mysql8.0"
}

variable "redis_node_type" {
  description = "ElastiCache Redis node type."
  type        = string
  default     = "cache.t3.micro"
}
