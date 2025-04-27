# modules/cloudwatch/logs/main.tf
resource "aws_cloudwatch_log_group" "application" {
  name              = "/aws/ec2/application"
  retention_in_days = 30
  tags              = { VpcId = var.vpc_id }
}
resource "aws_cloudwatch_log_group" "nginx" {
  name              = "/aws/ec2/nginx"
  retention_in_days = 30
  tags              = { VpcId = var.vpc_id }
}
resource "aws_cloudwatch_log_group" "system" {
  name              = "/aws/ec2/system"
  retention_in_days = 30
  tags              = { VpcId = var.vpc_id }
}
resource "aws_cloudwatch_log_group" "rds" {
  name              = "/aws/rds/mysql-logs"
  retention_in_days = 30
  tags              = { VpcId = var.vpc_id }
}
resource "aws_cloudwatch_log_group" "redis" {
  name              = "/aws/elasticache/redis-logs"
  retention_in_days = 30
  tags              = { VpcId = var.vpc_id }
}

resource "aws_cloudwatch_log_metric_filter" "application_errors" {
  name           = "application-errors"
  pattern        = "ERROR"
  log_group_name = aws_cloudwatch_log_group.application.name
  metric_transformation {
    name      = "ApplicationErrorCount"
    namespace = "Metrics"
    value     = "1"
  }
}
resource "aws_cloudwatch_log_metric_filter" "nginx_5xx_errors" {
  name           = "nginx-5xx-errors"
  pattern        = "[status=5*]"
  log_group_name = aws_cloudwatch_log_group.nginx.name
  metric_transformation {
    name      = "Nginx5xxErrorCount"
    namespace = "Metrics"
    value     = "1"
  }
}
