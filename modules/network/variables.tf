# modules/network/variables.tf
variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "aws_region" {
  description = "The AWS region where resources will be created"
  type        = string
}

variable "prefix" {
  description = "The prefix to use for resource names"
  type        = string
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC"
  type        = bool
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
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

variable "eip_domain" {
  description = "The domain for the Elastic IP"
  type        = string
}
variable "default_route_cidr_block" {
  description = "CIDR block used for default routes"
  type        = string
}

variable "lb_target_group" {
  description = "Target group settings"
  type = object({
    port     = number
    protocol = string
  })
}

variable "lb_health_check" {
  description = "Health check configuration"
  type = object({
    path                = string
    interval            = number
    timeout             = number
    healthy_threshold   = number
    unhealthy_threshold = number
    matcher             = string
  })
}

variable "alb_settings" {
  description = "Settings for the ALB"
  type = object({
    internal                  = bool
    enable_deletion_protection = bool
  })
}

variable "listener_settings" {
  description = "Listener settings including port, protocol, and default action type"
  type = object({
    port        = number
    protocol    = string
    action_type = string
  })
}
