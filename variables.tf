# variables.tf
variable "project" { type = string }
variable "aws_region" { type = string }
variable "environment" { type = string }
variable "vpc_cidr" { type = string }
variable "public_subnets" { type = list(string) }
variable "private_subnets" { type = list(string) }
variable "availability_zones" { type = list(string) }
variable "alert_email" { type = string }
variable "db_engine" { type = string }

variable "stag_instance_type" { type = string }
variable "stag_ami_id" { type = string }
variable "stag_db_instance_class" { type = string }
variable "stag_db_init_storage" { type = number }
variable "stag_db_username" { type = string }
variable "stag_db_password" { type = string }

variable "stag_db_delete_snapshot" { type = bool }
variable "stag_db_multi_az" { type = bool }
variable "stag_db_iam_authentication" { type = bool }


variable "stag_redis_node_type" { type = string }

variable "prod_instance_type" { type = string }
variable "prod_ami_id" { type = string }
variable "prod_db_instance_class" { type = string }
variable "prod_db_init_storage" { type = number }
variable "prod_db_username" { type = string }
variable "prod_db_password" { type = string }

variable "prod_db_delete_snapshot" { type = bool }
variable "prod_db_multi_az" { type = bool }
variable "prod_db_iam_authentication" { type = bool }


variable "prod_redis_node_type" { type = string }
