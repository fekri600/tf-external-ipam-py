# modules/network/variables.tf
variable "environment" {type = string}
variable "aws_region"         { type = string }
variable "prefix"        { type = string }
variable "vpc_cidr"           { type = string }
variable "public_subnets"     { type = list(string) }
variable "private_subnets"    { type = list(string) }
variable "availability_zones" { type = list(string) }

