#!/bin/bash

bucket=$(cat bootstrap/outputs/.backend_bucket)
dynamodb_table=$(cat bootstrap/outputs/.backend_table)
region=$(cat bootstrap/outputs/.backend_region)
key=$(cat bootstrap/outputs/.key)



cat > providers.tf <<EOF
terraform {
  required_version = "1.11.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.97.0"
    }
  }

  backend "s3" {
    bucket         = "$bucket"
    key            = "$key"
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