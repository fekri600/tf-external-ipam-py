variable "environment" {
  description = "The environment name (staging/production)."
  type        = string
}

variable "instance_type" {
  description = "Instance type to use for the application server."
  type        = string
}

variable "ami_id" {
  description = "The AMI ID to use for the EC2 instance."
  type        = string
}


variable "vpc_cidr" {
  description = "CIDR for the VPC."
  type        = string
}

variable "public_subnets" {
  description = "List of CIDRs for public subnets."
  type        = list(string)
}

variable "private_subnets" {
  description = "List of CIDRs for private subnets."
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones to use."
  type        = list(string)
}

variable "db_engine" {
  description = "Database engine (mysql, postgres, etc.)."
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
}

variable "db_storage" {
  description = "Allocated storage for the RDS instance (GB)."
  type        = number
}

variable "db_username" {
  description = "Database username."
  type        = string
}

variable "db_password" {
  description = "Database password."
  type        = string
  sensitive   = true
}

variable "db_parameter_group" {
  description = "Database parameter group name."
  type        = string
}

variable "redis_node_type" {
  description = "Node type for Redis cluster."
  type        = string
}
