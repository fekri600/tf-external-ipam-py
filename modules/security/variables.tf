variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
}


variable "prefix" {
  description = "The prefix to use for resource names"
  type        = string
}
variable "vpc_id" {
  type = string
}
