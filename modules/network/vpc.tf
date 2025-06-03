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
