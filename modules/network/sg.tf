
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
