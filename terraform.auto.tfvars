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
    port     = 80 # port number
    protocol = "HTTP"
  }

  lb_health_check = {
    path                = "/"
    interval            = 30 # seconds
    timeout             = 5  # seconds
    healthy_threshold   = 2  # number of successful checks
    unhealthy_threshold = 2  # number of failed checks
    matcher             = "200-399"
  }

  listener = {
    port = {
      http  = 80  # port number
      https = 443 # port number
    }
    protocol = {
      http  = "HTTP"
      https = "HTTPS"
    }
    action_type = "forward"
  }
}

# ==========================
# Securty Groups Configuration
# ==========================
security_groups = {
  port = {
    http  = 80   # port number
    https = 443  # port number
    mysql = 3306 # port number
    redis = 6379 # port number
    any   = 0    # port number (all)
  }
  protocol = {
    tcp = "tcp"
    any = "-1"
  }
}


# ==========================
# Launch Template Configuration
# 
# - architecture: CPU architecture type.
#     Options: "x86_64" (Intel/AMD), "arm64" (AWS Graviton - ARM-based)
# 
# - storage: EBS volume type.
#     Options: 
#       - "gp2": General Purpose SSD (default)
#       - "gp3": Next-generation SSD (better baseline performance and tunable IOPS/throughput) at a lower base price than gp2.
#       - "io1"/"io2": Provisioned IOPS SSD (for high-performance apps)
#       - "sc1"/"st1": Throughput-optimized HDD (for big data workloads)
# 
# - instance_type: EC2 instance type.
#     Examples:
#       - "t2.micro": Free tier eligible
#       - "t3.micro"/"t3a.micro": Burstable general purpose
#       - "t4g.micro": ARM-based, lowest cost (Graviton)
# ==========================
launch_template = {
  staging = {
    architecture  = "x86_64"
    storage       = "gp2"
    instance_type = "t2.micro"
  }

  production = {
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
    desired_capacity          = 2 # number of instances
    max_size                  = 2 # number of instances
    min_size                  = 2 # number of instances
    health_check_type         = "EC2"
    health_check_grace_period = 60 # seconds
    version                   = "$Latest"
    propagate_at_launch       = true
  }

  production = {
    desired_capacity          = 3 # number of instances
    max_size                  = 5 # number of instances
    min_size                  = 2 # number of instances
    health_check_type         = "EC2"
    health_check_grace_period = 60 # seconds
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
    initial_storage         = 20 # GB
    username                = "staging_user"
    password                = "staging_pass"
    delete_automated_backup = true
    iam_authentication      = true
    multi_az                = true
    backup_retention_period   = 0 # 0 means no backup
    backup_window             = "22:00-23:00" # optional; format is HH:MM-HH:MM in UTC
 

  }

  production = {
    engine                  = "mysql"
    instance_class          = "db.t3.micro"
    initial_storage         = 50 # GB
    username                = "prod_user"
    password                = "prod_pass"
    delete_automated_backup = true
    iam_authentication      = true
    multi_az                = true
    backup_retention_period   = 7
    backup_window             = "22:00-23:00" # optional; format is HH:MM-HH:MM in UTC
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
      num_cache_clusters = 1 # number of nodes
    }
  }

  production = {
    node_type = "cache.t3.micro"
    redis_settings = {
      engine             = "redis"
      num_cache_clusters = 1 # number of nodes
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

    # log‑derived metrics
    nginx_5xx = "Nginx5xxErrorCount"
    rds_error = "RDSErrorCount"
    redis_err = "RedisErrorCount"
    app_error = "ApplicationErrorCount"
  }

  threshold = {
    cpu        = 80        # percent
    memory     = 200000000 # bytes
    conn       = 100       # number of connections
    redis_conn = 100       # number of connections

    # all log metrics trip at 1
    nginx_5xx = 1 # count
    rds_error = 1 # count
    redis_err = 1 # count
    app_error = 1 # count
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
    evaluation_periods  = 1   # number of periods
    period              = 300 # seconds
    statistic           = "Sum"
  }

  alert_email = "alerts@example.com"
}


logs = {
  retention_in_days = 7 # days

  log_group_prefix = {
    staging    = "staging"
    production = "production"
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
      value     = "1" # constant value for log transformation
    }
  }
}
