

resource "aws_sns_topic" "alerts" {
  name = "alerts"
}

resource "aws_sns_topic_subscription" "email" {
  count     = var.alarm.alert_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alarm.alert_email
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
resource "aws_cloudwatch_metric_alarm" "log_metric_alarm" {
  for_each = local.log_alarm_specs

  alarm_name          = each.value.alarm_name
  metric_name         = each.value.metric_name
  namespace           = var.alarm.namespace["logs"]

  comparison_operator = var.alarm.common_settings.comparison_operator
  evaluation_periods  = var.alarm.common_settings.evaluation_periods
  period              = var.alarm.common_settings.period
  statistic           = var.alarm.common_settings.statistic
  threshold           = each.value.threshold

  alarm_description   = "Triggered when ${each.value.metric_name} exceeds threshold"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}
