# modules/cloudwatch/main.tf
module "alarms" {
  source      = "./alarms"
  aws_region  = var.aws_region
  alert_email = var.alert_email
  env_configs = var.env_configs
  alarm = var.alarm
}

module "dashboards" {
  source      = "./dashboards"
  aws_region  = var.aws_region
  env_configs = var.env_configs
}

module "logs" {
  source = "./logs"
  vpc_id = var.vpc_id
}
