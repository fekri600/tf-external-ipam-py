# modules/network/main.tf
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "${var.prefix}-${var.environment}-vpc-${substr(var.aws_region,0,2)}" }
}

resource "aws_subnet" "public" {
  count             = length(var.public_subnets)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = { Name = "${var.prefix}-${var.environment}-pub-subnet-${substr(var.availability_zones[count.index],length(var.availability_zones[count.index]) -1, 1)}" }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = { Name = "${var.prefix}-${var.environment}-priv-subnet-${substr(var.availability_zones[count.index],length(var.availability_zones[count.index]) -1, 1)}" }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.prefix}-${var.environment}-igw-${substr(var.aws_region,0,2)}" }
}

resource "aws_eip" "nat" {
  count = length(var.public_subnets)
  domain = "vpc"
  tags   = { Name = "${var.prefix}-${var.environment}-nat-ip" }
}

resource "aws_nat_gateway" "this" {
  count = length(var.public_subnets)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags = { Name = "${var.prefix}-${var.environment}-gtw-nat-${substr(var.availability_zones[count.index],length(var.availability_zones[count.index]) -1, 1)}" }
}

resource "aws_route_table" "private" {
  count  = length(var.private_subnets)
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[count.index].id
  }

  tags = {
    Name = "${var.prefix}-${var.environment}-priv-route-${substr(var.availability_zones[count.index],length(var.availability_zones[count.index]) -1, 1)}"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = { Name = "${var.prefix}-${var.environment}-pub-route-${substr(var.aws_region,0,2)}" }
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_lb_target_group" "nginx" {
  name     = "${var.prefix}-${var.environment}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.this.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }

  tags = {
    Name = "${var.prefix}-${var.environment}-tg"
  }
}

resource "aws_lb" "nginx" {
  name               = "${var.prefix}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  enable_deletion_protection = false

  tags = {
    Name = "${var.prefix}-${var.environment}-alb"
  }
}

resource "aws_lb_listener" "nginx" {
  load_balancer_arn = aws_lb.nginx.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx.arn
  }
}

resource "aws_security_group" "alb" {
  name        = "${var.prefix}-${var.environment}-alb-sg"
  description = "Allow HTTP/HTTPS from internet to ALB"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
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
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
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
    description      = "Allow MySQL access from EC2 security group"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups  = [aws_security_group.ec2.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
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
    description      = "Allow Redis access from EC2 instances"
    from_port        = 6379
    to_port          = 6379
    protocol         = "tcp"
    security_groups  = [aws_security_group.ec2.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-${var.environment}-redis-sg"
  }
}

resource "aws_db_subnet_group" "rds" {
  name       = "${var.prefix}-${var.environment}-rds-subnet-group"
  subnet_ids = aws_subnet.private[*].id
}

resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.prefix}-${var.environment}-redis-subnet-group"
  subnet_ids = aws_subnet.private[*].id
}



