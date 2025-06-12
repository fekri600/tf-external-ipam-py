# ======================
# Project Configuration
# ======================
project_settings = {
  project    = "i360moms"
  aws_region = "us-east-1"
}

# ======================
# Network Configuration
# ======================
network = {
  enable_dns_support   = true
  enable_dns_hostnames = true

  vpc_cidr                 = "10.0.0.0/16"
  public_subnets           = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets          = ["10.0.11.0/24", "10.0.12.0/24"]
  availability_zones       = ["us-east-1a", "us-east-1b"]
  eip_domain               = "vpc"
  default_route_cidr_block = "0.0.0.0/0"
}

# ==========================
# Load Balancer Configuration
# ==========================
load_balancer = {
  alb_settings = {
    internal                   = false
    enable_deletion_protection = false
    load_balancer_type         = "application"
  }

  lb_target_group = {
    port     = 80
    protocol = "HTTP"
  }

  lb_health_check = {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }

  listener = {
    port = {
      http  = 80
      https = 443
    }
    protocol = {
      http  = "HTTP"
      https = "HTTPS"
    }
    action_type = "forward"
  }
}

# ==========================
# Security Groups Configuration
# ==========================
security_groups = {
  port = {
    http  = 80
    https = 443
    mysql = 3306
    redis = 6379
    any   = 0
  }
  protocol = {
    tcp = "tcp"
    any = "-1"
  }
}

# ==========================
# Launch Template Configuration
# ==========================
launch_template = {
  staging = {
    architecture  = "x86_64"
    storage       = "gp2"
    instance_type = "t2.micro"
  }
}

# ==========================
# Auto Scaling Configuration
# ==========================
autoscaling = {
  staging = {
    desired_capacity          = 2
    max_size                  = 2
    min_size                  = 2
    health_check_type         = "EC2"
    health_check_grace_period = 60
    version                   = "$Latest"
    propagate_at_launch       = true
  }
}

# ====================
# Database Settings
# ====================
database = {
  staging = {
    engine                  = "mysql"
    instance_class          = "db.t3.micro"
    initial_storage         = 20
    username                = "staging_user"
    password                = "staging_pass"
    delete_automated_backup = true
    iam_authentication      = true
    multi_az                = true
    backup_retention_period = 0
    backup_window           = "22:00-23:00"
  }
}

# ====================
# Redis Configuration
# ====================
redis = {
  staging = {
    node_type = "cache.t3.micro"
    redis_settings = {
      engine             = "redis"
      num_cache_clusters = 1
    }
  }
}

# ====================
# Alarm Configuration
# ====================
alarm = {
  namespace = {
    ec2   = "AWS/EC2"
    rds   = "AWS/RDS"
    redis = "AWS/ElastiCache"
    logs  = "LogMetrics"
  }

  metric = {
    cpu        = "CPUUtilization"
    memory     = "FreeableMemory"
    conn       = "DatabaseConnections"
    redis_conn = "CurrConnections"
    nginx_5xx  = "Nginx5xxErrorCount"
    rds_error  = "RDSErrorCount"
    redis_err  = "RedisErrorCount"
    app_error  = "ApplicationErrorCount"
  }

  threshold = {
    cpu        = 80
    memory     = 200000000
    conn       = 100
    redis_conn = 100
    nginx_5xx  = 1
    rds_error  = 1
    redis_err  = 1
    app_error  = 1
  }

  dim = {
    ec2   = "AutoScalingGroupName"
    rds   = "DBInstanceIdentifier"
    redis = "CacheClusterId"
  }

  attr = {
    ec2   = "asg_name"
    rds   = "rds_id"
    redis = "redis_id"
  }

  common_settings = {
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods  = 1
    period              = 300
    statistic           = "Sum"
  }

  alert_email = "alerts@example.com"
}

# ====================
# Logs Configuration
# ====================
logs = {
  retention_in_days = 7

  log_group_prefix = {
    staging = "staging"
  }

  group_paths = {
    application      = "/aws/ec2/application"
    nginx            = "/aws/ec2/nginx"
    system           = "/aws/ec2/system"
    rds              = "/aws/rds/mysql-logs"
    redis            = "/aws/elasticache/redis-logs"
    ssm_connectivity = "/aws/ssm/connectivity"
  }

  filters = {
    pattern = {
      error  = "ERROR"
      status = "[status=5*]"
    }

    transformation = {
      name = {
        app   = "ApplicationErrorCount"
        nginx = "Nginx5xxErrorCount"
        rds   = "RDSErrorCount"
        redis = "RedisErrorCount"
      }
      namespace = "LogMetrics"
      value     = "1"
    }
  }
}

# ====================
# Dashboard Configuration
# ====================
dashboard_config = {
  create_combined_dashboard  = false
  create_separate_dashboards = true
} 