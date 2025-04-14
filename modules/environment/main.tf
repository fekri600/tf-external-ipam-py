# VPC
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.environment}-vpc"
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment}-public-${count.index}"
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.environment}-private-${count.index}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.environment}-igw"
  }
}

# Elastic IP for NAT
resource "aws_eip" "nat" {
  vpc = true

  tags = {
    Name = "${var.environment}-nat-eip"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${var.environment}-nat"
  }
}

# Security Group for EC2
resource "aws_security_group" "ec2" {
  name        = "${var.environment}-ec2-sg"
  description = "Allow SSH, HTTP, and HTTPS"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
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
    Name = "${var.environment}-ec2-sg"
  }
}

# EC2 Instance with Docker and Nginx
resource "aws_instance" "app" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private[0].id
  vpc_security_group_ids = [aws_security_group.ec2.id]
  key_name = "${var.environment}-ec2-app"

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y docker.io nginx
    systemctl start docker
    systemctl enable docker
    # (Insert your Nginx configuration commands or file copy commands here)
  EOF

  tags = {
    Name = "${var.environment}-ec2-app"
  }

}

# RDS Subnet Group
resource "aws_db_subnet_group" "this" {
  name       = "${var.environment}-rds-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "${var.environment}-rds-subnet-group"
  }
}

# RDS Database Instance
resource "aws_db_instance" "this" {
  identifier              = "${var.environment}-rds"
  engine                  = var.db_engine
  instance_class          = var.db_instance_class
  allocated_storage       = var.db_storage
  storage_type            = "gp2"
  username                = var.db_username
  password                = var.db_password
  skip_final_snapshot     = true
  vpc_security_group_ids  = [aws_security_group.ec2.id]
  db_subnet_group_name    = aws_db_subnet_group.this.name

  tags = {
    Name = "${var.environment}-rds"
  }
}

# ElastiCache Subnet Group
resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.environment}-redis-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "${var.environment}-redis-subnet-group"
  }
}

# ElastiCache Redis Cluster
resource "aws_elasticache_replication_group" "redis" {
  replication_group_id          = "${var.environment}-redis"
  replication_group_description = "${var.environment} Redis replication group"
  engine                        = "redis"
  node_type                     = var.redis_node_type
  number_cache_clusters         = 1
  automatic_failover_enabled    = true
  subnet_group_name             = aws_elasticache_subnet_group.this.name
  security_group_ids            = [aws_security_group.ec2.id]

  tags = {
    Name = "${var.environment}-redis"
  }
}

# CloudWatch Alarm for EC2 Status Check
resource "aws_cloudwatch_metric_alarm" "ec2_status" {
  alarm_name          = "${var.environment}-ec2-status-check-failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed_Instance"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "Alert if EC2 instance status check fails"

  dimensions = {
    InstanceId = aws_instance.app.id
  }
}
