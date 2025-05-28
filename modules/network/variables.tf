variable "environment" { type = string }
variable "prefix" { type = string }

variable "project_settings" {
  description = "Project and region configuration"
  type = object({
    project    = string
    aws_region = string
  })
}
variable "network" {
  type = object({
    enable_dns_support       = bool
    enable_dns_hostnames     = bool
    vpc_cidr                 = string
    public_subnets           = list(string)
    private_subnets          = list(string)
    availability_zones       = list(string)
    eip_domain               = string
    default_route_cidr_block = string
  })
}

variable "load_balancer" {
  description = "ALB settings, listener, target group and health check"
  type = object({
    alb_settings = object({
      internal                   = bool
      enable_deletion_protection = bool
      load_balancer_type         = string
    })

    lb_target_group = object({
      port     = number
      protocol = string
    })

    lb_health_check = object({
      path                = string
      interval            = number
      timeout             = number
      healthy_threshold   = number
      unhealthy_threshold = number
      matcher             = string
    })

    listener = object({ # ✅ Correct name is "listener"
      port = object({
        http  = number
        https = number
      })
      protocol = object({
        http  = string
        https = string
      })
      action_type = string
    })
  })
}




variable "security_groups" {
  description = "Security Groups configuration: ports and protocols"
  type = object({
    port = object({
      http  = number
      https = number
      mysql = number
      redis = number
      any   = number
    })
    protocol = object({
      tcp = string
      any = string
    })
  })
}