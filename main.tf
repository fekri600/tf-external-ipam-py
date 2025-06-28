module "network" {
  source           = "./modules/network"
  environment      = terraform.workspace
  prefix           = local.name_prefix
  project_settings = var.project_settings
  network          = var.network 
  ipam_path        = local.ipam
  load_balancer    = var.load_balancer
  security_groups  = var.security_groups
}
