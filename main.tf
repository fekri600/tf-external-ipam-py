module "network" {
  source           = "./modules/network"
  environment      = terraform.workspace
  prefix           = local.name_prefix
  project_settings = var.project_settings
  network          = var.network
  load_balancer    = var.load_balancer
  security_groups  = var.security_groups
}

module "environment" {
  source           = "./modules/environment"
  environment      = terraform.workspace
  project_settings = var.project_settings
  prefix           = local.name_prefix

  policies_path   = local.policies
  scripts_path    = local.scripts
  security_groups = var.security_groups

  launch_template       = var.launch_template[terraform.workspace]
  ec2_security_group_id = module.network.ec2_security_group_id
  autoscaling           = var.autoscaling[terraform.workspace]
  target_group_arn      = module.network.target_group_arn

  database              = var.database[terraform.workspace]
  private_subnet_ids    = module.network.private_subnet_ids
  db_security_group_ids = [module.network.db_security_group_id]
  rds_subnet_group_name = module.network.rds_subnet_group_name

  redis                   = var.redis[terraform.workspace]
  redis_subnet_group_name = module.network.redis_subnet_group_name
  redis_security_group_id = module.network.redis_security_group_id

  depends_on = [
    module.network,
  ]
}

module "cloudwatch" {
  source           = "./modules/cloudwatch"
  aws_region       = var.project_settings.aws_region
  alarm            = var.alarm
  logs             = var.logs
  dashboard_config = var.dashboard_config
  env_configs = {
    (terraform.workspace) = {
      asg_name = module.environment.asg_name
      rds_id   = module.environment.rds_id
      redis_id = module.environment.redis_id
    }
  }
  vpc_id = module.network.vpc_id

  depends_on = [
    module.network,
    module.environment,
  ]
}

