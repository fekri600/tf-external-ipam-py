locals {
  project     = var.project_settings.project
  region      = var.project_settings.aws_region
  name_prefix = var.project_settings.name_prefix
  #paths
  ipam     = "${path.root}/ipam"
}
