terraform {
  required_version = "1.11.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.94.1"
    }
  }

  #   backend "s3" {
  #     bucket         = "your-backend-bucket-name"
  #     key            = "terraform/state/infra_redesign_project.tfstate"
  #     region         = "us-east-1"
  #     dynamodb_table = "your-lock-table"
  #     encrypt        = true
  #
  #   }
}

provider "aws" {
  region = var.region
}

# Staging Environment
module "staging" {
  source             = "./modules/environment"
  environment        = "staging"
  instance_type      = var.instance_type
  ami_id             = var.ami_id
  vpc_cidr           = var.vpc_cidr
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  availability_zones = var.availability_zones
  db_engine          = var.db_engine
  db_instance_class  = var.db_instance_class
  db_storage         = var.db_storage
  db_username        = var.db_username
  db_password        = var.db_password
  db_parameter_group = var.db_parameter_group
  redis_node_type    = var.redis_node_type
}

# Production Environment
module "production" {
  source             = "./modules/environment"
  environment        = "production"
  instance_type      = var.instance_type
  ami_id             = var.ami_id
  vpc_cidr           = var.vpc_cidr
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  availability_zones = var.availability_zones
  db_engine          = var.db_engine
  db_instance_class  = var.db_instance_class
  db_storage         = var.db_storage
  db_username        = var.db_username
  db_password        = var.db_password
  db_parameter_group = var.db_parameter_group
  redis_node_type    = var.redis_node_type
}
