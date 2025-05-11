
project    = "nginx"
aws_region = "us-east-1"


# Network variables 
enable_dns_support   = true
enable_dns_hostnames = true

vpc_cidr                 = "10.0.0.0/16"
public_subnets           = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets          = ["10.0.11.0/24", "10.0.12.0/24"]
availability_zones       = ["us-east-1a", "us-east-1b"]
eip_domain               = "vpc"
default_route_cidr_block = "0.0.0.0/0"

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

alb_settings = {
  internal                   = false
  enable_deletion_protection = false
}

listener_settings = {
  port        = 80
  protocol    = "HTTP"
  action_type = "forward"
}



alert_email = "alerts@example.com"
db_engine   = "mysql" # TODO I guess we have aproblem here

stag_instance_type = "t3.micro"

autoscaling_settings = {
  desired_capacity          = 2
  max_size                  = 2
  min_size                  = 2
  health_check_type         = "EC2"
  health_check_grace_period = 60
  version                   = "$Latest"
  propagate_at_launch       = true
}

redis_settings = {
  engine             = "redis"
  num_cache_clusters = 1
}



stag_db_instance_class     = "db.t3.micro"
stag_db_init_storage       = 20
stag_db_username           = "staging_user"
stag_db_password           = "staging_pass"
stag_redis_node_type       = "cache.t3.micro"
stag_db_delete_snapshot    = true
stag_db_iam_authentication = false
stag_db_multi_az           = true



prod_instance_type         = "t3.micro"
prod_ami_id                = "ami-0abcd1234abcd1234"
prod_db_instance_class     = "db.t3.micro"
prod_db_init_storage       = 50
prod_db_username           = "staging_user"
prod_db_password           = "staging_pass"
prod_redis_node_type       = "cache.t3.micro"
prod_db_delete_snapshot    = true
prod_db_iam_authentication = false
prod_db_multi_az           = true




