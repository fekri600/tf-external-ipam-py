# ======================
# Project Configuration
# ======================
project_settings = {
  project     = "i2506cloud"
  aws_region  = "us-east-1"
  name_prefix = "fs"
}

# ======================
# Network Configuration
# ======================

network = {
    network_cidr             = "10.0.0.0/16"
    enable_dns_support       = true
    enable_dns_hostnames     = true
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
    any   = 0    # port number (all)
  }
  protocol = {
    tcp = "tcp"
    any = "-1"
  }
}

