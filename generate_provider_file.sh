#!/bin/bash

bucket=$(cat .backend_bucket)
dynamodb_table=$(cat .backend_table)
region=$(cat .backend_region)



cat > providers.tf <<EOF
terraform {
  required_version = "1.11.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.94.1"
    }
  }

  backend "s3" {
    bucket         = "$bucket"
    key            = "terraform/state/infra_redesign_project.tfstate"
    region         = "$region"
    dynamodb_table = "$dynamodb_table"
    encrypt        = true
  }
}

provider "aws" {
  region = "$region"
}
EOF

echo "✅ Generated providers.tf with backend and provider config." 