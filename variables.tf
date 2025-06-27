variable "project_settings" {
  description = "Project configuration settings"
  type = object({
    project     = string
    aws_region  = string
    name_prefix = string
  })
}

variable "network" {
  description = "Network configuration settings per environment with global flags"
  type = map(object({
    enable_dns_support       = bool
    enable_dns_hostnames     = bool
    availability_zones       = list(string)
    eip_domain               = string
    default_route_cidr_block = string
  }))
}

variable "network_cidr" {
  type = string
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

variable "launch_template" {
  description = "Launch template settings per environment"
  type = map(object({
    architecture  = string
    storage       = string
    instance_type = string
  }))
}

variable "autoscaling" {
  description = "Auto Scaling configuration per environment"
  type = map(object({
    desired_capacity          = number
    max_size                  = number
    min_size                  = number
    health_check_type         = string
    health_check_grace_period = number
    version                   = string
    propagate_at_launch       = bool
  }))
}

variable "database" {
  description = "Database settings per environment"
  type = map(object({
    engine                  = string
    instance_class          = string
    initial_storage         = number
    username                = string
    password                = string
    delete_automated_backup = bool
    iam_authentication      = bool
    multi_az                = bool
    backup_retention_period = number
    backup_window           = string
  }))
}

variable "redis" {
  description = "ElastiCache Redis settings per environment"
  type = map(object({
    node_type = string
    redis_settings = object({
      engine             = string
      num_cache_clusters = number
    })
  }))
}

variable "alarm" {
  description = "CloudWatch alarm configuration"
  type = object({
    namespace = object({
      ec2   = string
      rds   = string
      redis = string
      logs  = string
    })
    metric = object({
      cpu        = string
      memory     = string
      conn       = string
      redis_conn = string
      nginx_5xx  = string
      rds_error  = string
      redis_err  = string
      app_error  = string
    })
    threshold = object({
      cpu        = number
      memory     = number
      conn       = number
      redis_conn = number
      nginx_5xx  = number
      rds_error  = number
      redis_err  = number
      app_error  = number
    })
    dim = object({
      ec2   = string
      rds   = string
      redis = string
    })
    attr = object({
      ec2   = string
      rds   = string
      redis = string
    })
    common_settings = object({
      comparison_operator = string
      evaluation_periods  = number
      period              = number
      statistic           = string
    })
    alert_email = string
  })
}

variable "logs" {
  description = "CloudWatch Logs configuration"
  type = object({
    retention_in_days = number
    group_paths = object({
      application = string
      nginx       = string
      system      = string
      rds         = string
      redis       = string
    })
    filters = object({
      pattern = object({
        error  = string
        status = string
      })
      transformation = object({
        name = object({
          app   = string
          nginx = string
          rds   = string
          redis = string
        })
        namespace = string
        value     = string
      })
    })
  })
}


