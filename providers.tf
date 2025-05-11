terraform {
  required_version = "1.11.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.97.0"
    }
  }

  backend "s3" {
    bucket         = "backend-s3-bucket-1290"
    key            = "terraform/state/root.tfstate"
    region         = "us-east-1"
    dynamodb_table = "backend-d-db-table"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}
