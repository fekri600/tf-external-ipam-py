variable "project_settings" {
  description = "Project configuration settings"
  type = object({
    project     = string
    aws_region  = string
    name_prefix = string
  })
}

  
variable "network" {
  type = object({
    network_cidr  = string
    enable_dns_support       = bool
    enable_dns_hostnames     = bool
    availability_zones       = list(string)
    eip_domain               = string
    default_route_cidr_block = string
  })
}



variable "load_balancer" {
  description = "Load balancer configuration settings"
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
    listener = object({
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
  description = "Security groups configuration"
  type = object({
    port = object({
      http  = number
      https = number
      any   = number
    })
    protocol = object({
      tcp = string
      any = string
    })
  })
}
