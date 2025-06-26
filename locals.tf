locals {
  project     = var.project_settings.project
  region      = var.project_settings.aws_region
  name_prefix = var.project_settings.name_prefix
  #paths
  policies = "${path.root}/policies"
  scripts  = "${path.root}/scripts"
}
