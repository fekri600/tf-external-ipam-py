#!/bin/bash

bucket=$(cat modules/backend_setup/.backend_bucket)
dynamodb_table=$(cat modules/backend_setup/.backend_table)
region=$(cat modules/backend_setup/.backend_region)
key=$(cat modules/backend_setup/.key)



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