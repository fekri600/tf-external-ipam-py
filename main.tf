module "network" {
  source           = "./modules/network"
  environment      = "network"
  prefix           = local.name_prefix
  project_settings = var.project_settings
  network          = var.network
  load_balancer    = var.load_balancer
  security_groups  = var.security_groups
}


module "staging" {
  source      = "./modules/environment"
  environment = "staging"
  prefix      = local.name_prefix

  policies_path = local.policies
  scripts_path  = local.scripts

  launch_template       = var.launch_template.staging
  ec2_security_group_id = module.network.ec2_security_group_id
  autoscaling           = var.autoscaling.staging
  target_group_arn      = module.network.target_group_arn

  database              = var.database.staging
  private_subnet_ids    = module.network.private_subnet_ids
  db_security_group_ids = [module.network.db_security_group_id]
  rds_subnet_group_name = module.network.rds_subnet_group_name

  redis                   = var.redis.staging
  redis_subnet_group_name = module.network.redis_subnet_group_name
  redis_security_group_id = module.network.redis_security_group_id

  depends_on = [
    module.network,
  ]
}
module "production" {
  source      = "./modules/environment"
  environment = "production"
  prefix      = local.name_prefix

  policies_path = local.policies
  scripts_path  = local.scripts

  launch_template       = var.launch_template.production
  ec2_security_group_id = module.network.ec2_security_group_id
  autoscaling           = var.autoscaling.production
  target_group_arn      = module.network.target_group_arn

  database              = var.database.production
  private_subnet_ids    = module.network.private_subnet_ids
  db_security_group_ids = [module.network.db_security_group_id]

  rds_subnet_group_name = module.network.rds_subnet_group_name

  redis                   = var.redis.production
  redis_subnet_group_name = module.network.redis_subnet_group_name
  redis_security_group_id = module.network.redis_security_group_id

  depends_on = [
    module.network,
  ]
}


module "cloudwatch" {
  source      = "./modules/cloudwatch"
  aws_region  = var.project_settings.aws_region
  alert_email = var.alerting.email
  alarm = var.alarm
  logs = var.logs
  env_configs = {
    staging = {
      asg_name = module.staging.asg_name
      rds_id   = module.staging.rds_id
      redis_id = module.staging.redis_id
    }
    production = {
      asg_name = module.production.asg_name
      rds_id   = module.production.rds_id
      redis_id = module.production.redis_id
    }
  }
  vpc_id = module.network.vpc_id

  depends_on = [
    module.network,
    module.staging,
    module.production,
  ]
}


