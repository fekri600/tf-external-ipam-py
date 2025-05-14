

resource "aws_sns_topic" "alerts" {
  name = "alerts"
}

resource "aws_sns_topic_subscription" "email" {
  count     = var.alert_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_metric_alarm" "this" {
  for_each = merge([
    for env, cfg in var.env_configs : {
      for name, spec in local.alarm_specs : "${env}_${name}" => {
        ns   = spec.namespace
        met  = spec.metric
        thr  = spec.threshold
        dimk = spec.dim
        id   = lookup(cfg, spec.attr)
      }
    }
  ]...)

  alarm_name          = each.key
  comparison_operator = var.alarm.common_settings.comparison_operator
  evaluation_periods  = var.alarm.common_settings.evaluation_periods
  metric_name         = each.value.met
  namespace           = each.value.ns
  period              = var.alarm.common_settings.period
  statistic           = var.alarm.common_settings.statistic
  threshold           = each.value.thr
  alarm_description   = "Alarm for ${each.key}"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    (each.value.dimk) = each.value.id
  }
}
resource "aws_cloudwatch_metric_alarm" "nginx_5xx_alarm" {
  alarm_name          = "${var.logs.og_group_prefix}-Nginx5xxErrors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Nginx5xxErrorCount"
  namespace           = "LogMetrics"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Triggered when NGINX 5xx errors are detected"
}

resource "aws_cloudwatch_metric_alarm" "rds_error_alarm" {
  alarm_name          = "${var.logs.og_group_prefix}-RDSErrors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "RDSErrorCount"
  namespace           = "LogMetrics"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Triggered when RDS errors occur"
}

resource "aws_cloudwatch_metric_alarm" "redis_error_alarm" {
  alarm_name          = "${var.logs.og_group_prefix}-RedisErrors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "RedisErrorCount"
  namespace           = "LogMetrics"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Triggered when Redis errors are detected"
}
# Optional Alarms (basic examples)
resource "aws_cloudwatch_metric_alarm" "application_error_alarm" {
  alarm_name          = "${var.logs.og_group_prefix}-ApplicationErrors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApplicationErrorCount"
  namespace           = "LogMetrics"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Triggered when application errors exceed threshold"
}