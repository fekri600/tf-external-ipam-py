module "network" {
  source      = "./modules/network"
  environment = "network"
  aws_region  = var.aws_region
  prefix      = local.name_prefix

  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  vpc_cidr                 = var.vpc_cidr
  public_subnets           = var.public_subnets
  private_subnets          = var.private_subnets
  availability_zones       = var.availability_zones
  eip_domain               = var.eip_domain
  default_route_cidr_block = var.default_route_cidr_block
  lb_target_group          = var.lb_target_group
  lb_health_check          = var.lb_health_check
  alb_settings             = var.alb_settings
  listener_settings        = var.listener_settings



}

module "security" {
  source      = "./modules/security"
  prefix      = local.name_prefix
  environment = "security"
  vpc_id      = module.network.vpc_id
  depends_on  = [module.network]

}


module "staging" {
  source               = "./modules/environment"
  environment          = "staging"
  prefix               = local.name_prefix
  ami                  = local.ami
  policies_path        = local.policies
  instance_type        = var.stag_instance_type
  security_group_id    = module.security.ce2_security_group_id
  scripts_path         = local.scripts
  autoscaling_settings = var.autoscaling_settings
  target_group_arn   = module.network.target_group_arn
  private_subnet_ids = module.network.private_subnet_ids

  db_engine               = var.db_engine
  db_instance_class       = var.stag_db_instance_class
  db_storage              = var.stag_db_init_storage
  db_username             = var.stag_db_username
  db_password             = var.stag_db_password
  db_security_group_ids   = [module.security.db_security_group_id]
  db_delete_snapshot    = var.stag_db_delete_snapshot
  db_multi_az           = var.stag_db_multi_az
  db_iam_authentication = var.stag_db_iam_authentication


  redis_settings = var.redis_settings 
  redis_security_group_id = module.security.redis_security_group_id
  rds_subnet_group_name   = module.network.rds_subnet_group_name
  redis_subnet_group_name = module.network.redis_subnet_group_name
  redis_node_type = var.stag_redis_node_type

  depends_on = [
    module.network,
    module.security
  ]
}

module "production" {
  source                  = "./modules/environment"
  environment             = "production"
  prefix                  = local.name_prefix
  instance_type           = var.prod_instance_type
  security_group_id       = module.network.ec2_security_group_id
  redis_security_group_id = module.network.redis_security_group_id
  arch                    = local.arch

  private_subnet_ids = module.network.private_subnet_ids
  target_group_arn   = module.network.target_group_arn

  db_engine               = var.db_engine
  db_instance_class       = var.prod_db_instance_class
  db_storage              = var.prod_db_init_storage
  db_username             = var.prod_db_username
  db_password             = var.prod_db_password
  db_security_group_ids   = [module.network.db_security_group_id]
  rds_subnet_group_name   = module.network.rds_subnet_group_name
  redis_subnet_group_name = module.network.redis_subnet_group_name

  db_delete_snapshot    = var.prod_db_delete_snapshot
  db_multi_az           = var.prod_db_multi_az
  db_iam_authentication = var.prod_db_iam_authentication

  redis_node_type = var.prod_redis_node_type

  depends_on = [
    module.network,
    module.security
  ]
}

module "cloudwatch" {
  source      = "./modules/cloudwatch"
  aws_region  = var.aws_region
  alert_email = var.alert_email
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
    module.security,
    module.staging,
    module.production,
  ]
}


