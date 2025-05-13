# ======================
# Project Configuration
# ======================
variable "project_settings" {
  description = "Project and region configuration"
  type = object({
    project    = string
    aws_region = string
  })
}


# ======================
# Network Configuration
# ======================
variable "network" {
  description = "VPC and subnet configuration"
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

# ==========================
# Securty Groups Configuration
# ==========================
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



# ==========================
# Load Balancer Configuration
# ==========================
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

    listener = object({
      port        = number
      protocol    = string
      action_type = string
    })
  })
}
# ==========================
# Launch Template Variable
# ==========================
variable "launch_template" {
  description = "Launch template configuration for staging and production"
  type = object({
    staging = object({
      architecture  = string
      storage       = string
      instance_type = string
    })
    production = object({
      architecture  = string
      storage       = string
      instance_type = string
    })
  })
}

# ==========================
# Auto Scaling Configuration
# ==========================
variable "autoscaling" {
  description = "Auto Scaling configuration for staging and production"
  type = object({
    staging = object({
      desired_capacity          = number
      max_size                  = number
      min_size                  = number
      health_check_type         = string
      health_check_grace_period = number
      version                   = string
      propagate_at_launch       = bool
    })
    production = object({
      desired_capacity          = number
      max_size                  = number
      min_size                  = number
      health_check_type         = string
      health_check_grace_period = number
      version                   = string
      propagate_at_launch       = bool
    })
  })
}


# ====================
# Database Settings
# ====================
variable "database" {
  description = "RDS instance settings for staging and production"
  type = object({
    staging = object({
      engine                  = string
      instance_class          = string
      initial_storage         = number
      username                = string
      password                = string
      delete_automated_backup = bool
      iam_authentication      = bool
      multi_az                = bool
    })
    production = object({
      engine                  = string
      instance_class          = string
      initial_storage         = number
      username                = string
      password                = string
      delete_automated_backup = bool
      iam_authentication      = bool
      multi_az                = bool
    })
  })
  sensitive = true
}



# ====================
# Redis Configuration
# ====================
variable "redis" {
  description = "ElastiCache Redis configuration for staging and production"
  type = object({
    staging = object({
      node_type = string
      redis_settings = object({
        engine             = string
        num_cache_clusters = number
      })
    })
    production = object({
      node_type = string
      redis_settings = object({
        engine             = string
        num_cache_clusters = number
      })
    })
  })
}



# ====================
# Alerting
# ====================
variable "alerting" {
  description = "Alerting configuration"
  type = object({
    alert_email = string
  })
}


