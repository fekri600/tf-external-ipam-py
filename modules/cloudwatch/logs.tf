resource "aws_cloudwatch_log_group" "this" {
  for_each = local.log_groups

  name              = each.value.full_name
  retention_in_days = var.logs.retention_in_days
  tags              = { VpcId = var.vpc_id }
}

# Metric Filters

resource "aws_cloudwatch_log_metric_filter" "app_errors" {
  name           = var.logs.filters.name.app
  pattern        = var.logs.filters.pattern.error
  log_group_name = aws_cloudwatch_log_group.app.name

  metric_transformation {
    name      = var.logs.filters.transformation.name.app
    namespace = var.logs.filters.transformation.namespace
    value     = var.logs.filters.transformation.value
  }
}

resource "aws_cloudwatch_log_metric_filter" "nginx_5xx" {
  name           = var.logs.filters.name.nginx
  pattern        = var.logs.filters.pattern.status
  log_group_name = aws_cloudwatch_log_group.nginx.name

  metric_transformation {
    name      = var.logs.filters.transformation.name.nginx
    namespace = var.logs.filters.transformation.namespace
    value     = var.logs.filters.transformation.value
  }
}

resource "aws_cloudwatch_log_metric_filter" "rds_errors" {
  name           = var.logs.filters.name.rds
  pattern        = var.logs.filters.pattern.error
  log_group_name = aws_cloudwatch_log_group.rds.name

  metric_transformation {
    name      = var.logs.filters.transformation.name.rds
    namespace = var.logs.filters.transformation.namespace
    value     = var.logs.filters.transformation.value
  }
}

resource "aws_cloudwatch_log_metric_filter" "redis_errors" {
  name           = var.logs.filters.name.redis
  pattern        = var.logs.filters.pattern.error
  log_group_name = aws_cloudwatch_log_group.redis.name

  metric_transformation {
    name      = var.logs.filters.transformation.name.redis
    namespace = var.logs.filters.transformation.namespace
    value     = var.logs.filters.transformation.value
  }
}
