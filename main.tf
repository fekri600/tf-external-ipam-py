module "network" {
  source             = "./modules/network"
  environment        = "network"
  aws_region         = var.aws_region
  prefix             = local.name_prefix
  vpc_cidr           = var.vpc_cidr
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  availability_zones = var.availability_zones
}

module "staging" {
  source                  = "./modules/environment"
  environment             = "staging"
  prefix                  = local.name_prefix
  instance_type           = var.stag_instance_type
  security_group_id       = module.network.ec2_security_group_id
  redis_security_group_id = module.network.redis_security_group_id
  arch                    = local.arch

  private_subnet_ids = module.network.private_subnet_ids
  target_group_arn   = module.network.target_group_arn

  db_engine               = var.db_engine
  db_instance_class       = var.stag_db_instance_class
  db_storage              = var.stag_db_init_storage
  db_username             = var.stag_db_username
  db_password             = var.stag_db_password
  db_security_group_ids   = [module.network.db_security_group_id]
  rds_subnet_group_name   = module.network.rds_subnet_group_name
  redis_subnet_group_name = module.network.redis_subnet_group_name

  db_delete_snapshot    = var.stag_db_delete_snapshot
  db_multi_az           = var.stag_db_multi_az
  db_iam_authentication = var.stag_db_iam_authentication

  redis_node_type = var.stag_redis_node_type

  depends_on = [module.network]
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

  depends_on = [module.network]
}

#module "cloudwatch" {
#  source      = "./modules/cloudwatch"
#  aws_region  = var.aws_region
#  alert_email = var.alert_email
#  env_configs = {
#    staging    = module.staging
#    production = module.production
#  }
#  vpc_id = module.network.vpc_id
#
#  depends_on = [
#    module.network,
#    module.staging,
#    module.production,
#  ]
#}
