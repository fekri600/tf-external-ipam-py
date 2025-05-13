# ======================
# Project Configuration
# ======================
project_settings = {
  project    = "nginx"
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
    port        = 80
    protocol    = "HTTP"
    action_type = "forward"
  }
}

# ==========================
# Securty Groups Configuration
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
    desired_capacity          = 2
    max_size                  = 2
    min_size                  = 2
    health_check_type         = "EC2"
    health_check_grace_period = 60
    version                   = "$Latest"
    propagate_at_launch       = true
  }

  production = {
    desired_capacity          = 3
    max_size                  = 5
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
    iam_authentication      = false
    multi_az                = true
  }

  production = {
    engine                  = "mysql"
    instance_class          = "db.t3.micro"
    initial_storage         = 50
    username                = "prod_user"
    password                = "prod_pass"
    delete_automated_backup = true
    iam_authentication      = false
    multi_az                = true
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

  production = {
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
  }

  metric = {
    cpu         = "CPUUtilization"
    ram         = "MemoryUtilization"
    disk_read   = "DiskReadOps"
    disk_write  = "DiskWriteOps"
    nic_in      = "NetworkIn"
    nic_out     = "NetworkOut"
    free_space  = "FreeStorageSpace"
    free_memory = "FreeableMemory"
    replica     = "ReplicaLag"
    eviction    = "Evictions"
  }

  threshold = {
    cpu         = 80             # % utilization
    ram         = 80             # % utilization
    disk_read   = 1000           # IOPS (operations per second)
    disk_write  = 1000           # IOPS (operations per second)
    nic_in      = 50000000       # Bytes (approx. 47.7 MB)
    nic_out     = 50000000       # Bytes (approx. 47.7 MB)
    free_space  = 20000000000    # Bytes (~20 GB remaining)
    free_memory = 500000000      # Bytes (~476 MB remaining)
    replica     = 60             # Seconds of replication lag
    eviction    = 100            # Count of evictions
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
    evaluation_periods  = 2     # Number of consecutive periods the metric must breach the threshold to trigger the alarm
    period              = 300   # Period in seconds over which the metric is evaluated (e.g., 300 = 5 minutes)
    statistic           = "Average"
  }
}

# ====================
# Alerting Configuration
# ====================
alerting = {
  alert_email = "alerts@example.com"
}
