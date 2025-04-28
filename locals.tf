locals {
  project     = var.project
  environment = var.environment
  region      = var.aws_region
  name_prefix = local.project

  # AMI configuration
  arch = "x86_64" # All t2, t3, and t3a are x86_64 architecture
}