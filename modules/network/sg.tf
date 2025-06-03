
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