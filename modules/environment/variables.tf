# modules/environment/variables.tf
variable "environment"       { type = string }
variable "prefix"            { type = string }
variable "private_subnet_ids"{ type = list(string) }
variable "security_group_id" { type = string }
variable "instance_type"     { type = string }
variable "ami_id"            { type = string }

variable "db_engine"         { type = string }
variable "db_instance_class" { type = string }
variable "db_storage"        { type = number }
variable "db_username"       { type = string }
variable "db_password"       { type = string }
variable "db_delete_snapshot" {type = bool}
variable "db_security_group_ids" {type = list(string)}
variable "db_multi_az" {type = bool}
variable "db_iam_authentication" {type = bool}

variable "redis_node_type"   { type = string }
variable "target_group_arn" {
  description = "ARN of the ALB target group"
  type        = string
}