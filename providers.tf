terraform {
  required_version = "1.11.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.94.1"
    }
  }

  backend "s3" {
    bucket         = "nginx-backend-rsm"
    key            = "terraform/state/infra_redesign_project.tfstate"
    region         = "us-east-1"
    dynamodb_table = "backend-d-db-table"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}
