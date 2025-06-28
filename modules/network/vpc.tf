# in your module/network/vpc.tf

resource "aws_vpc" "this" {
  cidr_block           = local.vpc_cidr
  enable_dns_support   = var.network.enable_dns_support
  enable_dns_hostnames = var.network.enable_dns_hostnames
  tags = {
    Name = "${var.prefix}-${var.environment}-vpc"
  }
}

resource "aws_subnet" "public" {
  count             = length(var.network.availability_zones)
  vpc_id            = aws_vpc.this.id
  cidr_block        = local.publics[count.index]
  availability_zone = var.network.availability_zones[count.index]
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  count             = length(var.network.availability_zones)
  vpc_id            = aws_vpc.this.id
  cidr_block        = local.privates[count.index]
  availability_zone = var.network.availability_zones[count.index]
}


# Attach an Internet Gateway to the VPC for public internet access
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.prefix}-${var.environment}-igw-${substr(var.project_settings.aws_region, 0, 2)}" }
}

# Allocate Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count  = length(aws_subnet.public[*])
  domain = var.network.eip_domain
  tags   = { Name = "${var.prefix}-${var.environment}-nat-ip" }
}

# Create NAT Gateways in public subnets to allow private subnets to access the internet
resource "aws_nat_gateway" "this" {
  count         = length(aws_subnet.public[*])
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags          = { Name = "${var.prefix}-${var.environment}-gtw-nat-${substr(var.network.availability_zones[count.index], length(var.network.availability_zones[count.index]) - 1, 1)}" }
}

# Create route tables for private subnets with route to NAT Gateway
resource "aws_route_table" "private" {
  count  = length(aws_subnet.private[*])
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
  count          = length(aws_subnet.private[*])
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
  count          = length(aws_subnet.public[*])
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}


