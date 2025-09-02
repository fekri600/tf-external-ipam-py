module "az_1st_region" {
  source = "./modules/az"
  providers = {
    aws = aws.primary
  }
}

module "az_2nd_region" {
  source = "./modules/az"
  providers = {
    aws = aws.secondary
  }
}

module "network_1st_region" {
  source                = "./env/1st-region/network"
  environment           = terraform.workspace
  region                = var.region_1st    
  project_name          = var.project_name
  availability_zones    = slice(module.az_1st_region.az_names, 0, 3)
  public_subnets_count  = length(slice(module.az_1st_region.az_names, 0, 2))
  private_subnets_count = length(slice(module.az_1st_region.az_names, 0, 3))
  providers = {
    aws = aws.primary
  }
}

module "network_2nd_region" {
  source                = "./env/2nd-region/network"
  environment           = terraform.workspace
  region                = var.region_2nd
  project_name          = var.project_name
  availability_zones    = slice(module.az_2nd_region.az_names, 0, 2)
  public_subnets_count  = length(slice(module.az_2nd_region.az_names, 0, 2))
  private_subnets_count = length(slice(module.az_2nd_region.az_names, 0, 2))
  providers = {
    aws = aws.secondary
  }
}
