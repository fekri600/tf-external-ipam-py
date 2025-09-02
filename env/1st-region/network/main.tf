module "ipam" {
  source                = "../../../modules/ipam"
  environment           = var.environment
  vpc_name              = "${var.project_name}-${var.environment}-${var.region}-vpc"
  public_subnets_count  = var.public_subnets_count
  private_subnets_count = var.private_subnets_count
}

module "vpc" {
  source     = "../../../modules/vpc"
  cidr_block = module.ipam.vpc_cidr
  tags       = { Name = "${var.project_name}-${var.environment}-${var.region}-vpc" }
}

module "public_subnets_az_a" {
  source                  = "../../../modules/subnets"
  vpc_id                  = module.vpc.vpc_id
  cidr_block              = module.ipam.publics[0]
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true
  name                    = "${var.project_name}-${var.environment}-${var.availability_zones[0]}-public-subnet"
}

module "private_subnets_az_a" {
  source                  = "../../../modules/subnets"
  vpc_id                  = module.vpc.vpc_id
  cidr_block              = module.ipam.privates[0]
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = false
  name                    = "${var.project_name}-${var.environment}-${var.availability_zones[0]}-private-subnet"
}

module "public_subnets_az_b" {
  source                  = "../../../modules/subnets"
  vpc_id                  = module.vpc.vpc_id
  cidr_block              = module.ipam.publics[1]
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = true
  name                    = "${var.project_name}-${var.environment}-${var.availability_zones[1]}-public-subnet"
}

module "private_subnets_az_b" {
  source                  = "../../../modules/subnets"
  vpc_id                  = module.vpc.vpc_id
  cidr_block              = module.ipam.privates[1]
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = false
  name                    = "${var.project_name}-${var.environment}-${var.availability_zones[1]}-private-subnet"
}

module "private_subnets_az_c" {
  source                  = "../../../modules/subnets"
  vpc_id                  = module.vpc.vpc_id
  cidr_block              = module.ipam.privates[2]
  availability_zone       = var.availability_zones[2]
  map_public_ip_on_launch = false
  name                    = "${var.project_name}-${var.environment}-${var.availability_zones[2]}-private-subnet"
}