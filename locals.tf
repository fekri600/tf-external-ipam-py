locals {
  project     = var.project
  environment = var.environment
  region      = var.aws_region
  name_prefix = "${local.project}-${local.environment}"
}