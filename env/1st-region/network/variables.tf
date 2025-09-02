variable "environment" { type = string }
variable "region" { type = string }
variable "availability_zones" { type = list(string) }
variable "public_subnets_count" { type = number }
variable "private_subnets_count" { type = number }
variable "project_name" { type = string }