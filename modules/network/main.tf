# Create the VPC with DNS support and custom tag
resource "aws_vpc" "this" {
  cidr_block           = var.network.vpc_cidr
  enable_dns_support   = var.network.enable_dns_support
  enable_dns_hostnames = var.network.enable_dns_hostnames
  tags                 = { Name = "${var.prefix}-${var.environment}-vpc-${substr(var.project_settings.aws_region, 0, 2)}" }
}

# Create public subnets in specified availability zones
resource "aws_subnet" "public" {
  count             = length(var.network.public_subnets)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.network.public_subnets[count.index]
  availability_zone = var.network.availability_zones[count.index]
  tags              = { Name = "${var.prefix}-${var.environment}-pub-subnet-${substr(var.network.availability_zones[count.index], length(var.network.availability_zones[count.index]) - 1, 1)}" }
}

# Create private subnets in specified availability zones
resource "aws_subnet" "private" {
  count             = length(var.network.private_subnets)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.network.private_subnets[count.index]
  availability_zone = var.network.availability_zones[count.index]
  tags              = { Name = "${var.prefix}-${var.environment}-priv-subnet-${substr(var.network.availability_zones[count.index], length(var.network.availability_zones[count.index]) - 1, 1)}" }
}

# Attach an Internet Gateway to the VPC for public internet access
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.prefix}-${var.environment}-igw-${substr(var.project_settings.aws_region, 0, 2)}" }
}

# Allocate Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count  = length(var.network.public_subnets)
  domain = var.network.eip_domain
  tags   = { Name = "${var.prefix}-${var.environment}-nat-ip" }
}

# Create NAT Gateways in public subnets to allow private subnets to access the internet
resource "aws_nat_gateway" "this" {
  count         = length(var.network.public_subnets)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags          = { Name = "${var.prefix}-${var.environment}-gtw-nat-${substr(var.network.availability_zones[count.index], length(var.network.availability_zones[count.index]) - 1, 1)}" }
}

# Create route tables for private subnets with route to NAT Gateway
resource "aws_route_table" "private" {
  count  = length(var.network.private_subnets)
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = var.network.default_route_cidr_block  
    nat_gateway_id = aws_nat_gateway.this[count.index].id
  }

  tags = {
    Name = "${var.prefix}-${var.environment}-priv-route-${substr(var.network.availability_zones[count.index], length(var.network.availability_zones[count.index]) - 1, 1)}"
  }
}

# Associate private subnets with their corresponding private route tables
resource "aws_route_table_association" "private" {
  count          = length(var.network.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Create a public route table with a default route to the Internet Gateway
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = var.network.default_route_cidr_block
    gateway_id = aws_internet_gateway.this.id
  }

  tags = { Name = "${var.prefix}-${var.environment}-pub-route-${substr(var.project_settings.aws_region, 0, 2)}" }
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public" {
  count          = length(var.network.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Create an RDS Subnet Group using private subnets
resource "aws_db_subnet_group" "rds" {
  name       = "${var.prefix}-${var.environment}-rds-subnet-group"
  subnet_ids = aws_subnet.private[*].id
}

# Create an ElastiCache Subnet Group using private subnets
resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.prefix}-${var.environment}-redis-subnet-group"
  subnet_ids = aws_subnet.private[*].id
}


# Create an ALB Target Group with health checks configured
resource "aws_lb_target_group" "nginx" {
  name     = "${var.prefix}-${var.environment}-tg"
  port     = var.load_balancer.lb_target_group.port
  protocol = var.load_balancer.lb_target_group.protocol
  vpc_id   = aws_vpc.this.id

  health_check {
    path                = var.load_balancer.lb_health_check.path
    interval            = var.load_balancer.lb_health_check.interval
    timeout             = var.load_balancer.lb_health_check.timeout
    healthy_threshold   = var.load_balancer.lb_health_check.healthy_threshold
    unhealthy_threshold = var.load_balancer.lb_health_check.unhealthy_threshold
    matcher             = var.load_balancer.lb_health_check.matcher
  }

  tags = {
    Name = "${var.prefix}-${var.environment}-tg"
  }
}

# Create the Application Load Balancer (ALB)
resource "aws_lb" "nginx" {
  name               = "${var.prefix}-${var.environment}-alb"
  load_balancer_type = var.load_balancer.alb_settings.load_balancer_type
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id
  internal           = var.load_balancer.alb_settings.internal
  enable_deletion_protection = var.load_balancer.alb_settings.enable_deletion_protection

  tags = {
    Name = "${var.prefix}-${var.environment}-alb"
  }
}

# Create a listener on the ALB for incoming HTTP/HTTPS traffic
resource "aws_lb_listener" "nginx" {
  load_balancer_arn = aws_lb.nginx.arn
  port              = var.load_balancer.listener.port
  protocol          = var.load_balancer.listener.protocol

  default_action {
    type             = var.load_balancer.listener.action_type
    target_group_arn = aws_lb_target_group.nginx.arn
  }
}



resource "aws_security_group" "alb" {
  name        = "${var.prefix}-${var.environment}-alb-sg"
  description = "Allow HTTP/HTTPS from internet to ALB"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = var.security_groups.port.http
    to_port     = var.security_groups.port.http
    protocol    = var.security_groups.protocol.tcp
    cidr_blocks = [var.network.default_route_cidr_block]
  }

  ingress {
    from_port   = var.security_groups.port.https
    to_port     = var.security_groups.port.https
    protocol    = var.security_groups.protocol.tcp
    cidr_blocks = [var.network.default_route_cidr_block]
  }

  egress {
    from_port   = var.security_groups.port.any
    to_port     = var.security_groups.port.any
    protocol    = var.security_groups.protocol.any
    cidr_blocks = [var.network.default_route_cidr_block]
  }

  tags = {
    Name = "${var.prefix}-${var.environment}-alb-sg"
  }
}

resource "aws_security_group" "ec2" {
  name        = "${var.prefix}-${var.environment}-ec2-sg"
  description = "Allow traffic from ALB"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = var.security_groups.port.http
    to_port     = var.security_groups.port.http
    protocol    = var.security_groups.protocol.tcp
    cidr_blocks = [var.network.default_route_cidr_block]
  }


   egress {
    from_port   = var.security_groups.port.any
    to_port     = var.security_groups.port.any
    protocol    = var.security_groups.protocol.any
    cidr_blocks = [var.network.default_route_cidr_block]
  }

  tags = {
    Name = "${var.prefix}-${var.environment}-ec2-sg"
  }
}

resource "aws_security_group" "rds" {
  name        = "${var.prefix}-${var.environment}-rds-sg"
  description = "Allow DB access from EC2"
  vpc_id      = aws_vpc.this.id

  ingress {
    description     = "Allow MySQL access from EC2 security group"
    from_port       = var.security_groups.port.mysql
    to_port         = var.security_groups.port.mysql
    protocol        = var.security_groups.protocol.tcp
    security_groups = [aws_security_group.ec2.id]
  }

 egress {
    from_port   = var.security_groups.port.any
    to_port     = var.security_groups.port.any
    protocol    = var.security_groups.protocol.any
    cidr_blocks = [var.network.default_route_cidr_block]
  }

  tags = {
    Name = "${var.prefix}-${var.environment}-rds-sg"
  }
}

resource "aws_security_group" "redis" {
  name        = "${var.prefix}-${var.environment}-redis-sg"
  description = "Allow Redis access from EC2"
  vpc_id      = aws_vpc.this.id

  ingress {
    description     = "Allow Redis access from EC2 instances"
    from_port       = var.security_groups.port.redis
    to_port         = var.security_groups.port.redis
    protocol        = var.security_groups.protocol.tcp
    security_groups = [aws_security_group.ec2.id]
  }

  egress {
    from_port   = var.security_groups.port.any
    to_port     = var.security_groups.port.any
    protocol    = var.security_groups.protocol.any
    cidr_blocks = [var.network.default_route_cidr_block]
  }

  tags = {
    Name = "${var.prefix}-${var.environment}-redis-sg"
  }
}