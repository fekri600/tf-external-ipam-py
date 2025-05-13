# modules/cloudwatch/alarms/main.tf

locals {
  alarm_specs = merge([
    for service in keys(var.alarm.namespace) : {
      for metric_key in keys(var.alarm.metric) :
      "${service}_${metric_key}" => {
        namespace = var.alarm.namespace[service]
        metric    = var.alarm.metric[metric_key]
        threshold = var.alarm.threshold[metric_key]
        dim       = var.alarm.dim[service]
        attr      = var.alarm.attr[service]
      }
    }
    if contains(keys(var.alarm.dim), service)
      && contains(keys(var.alarm.attr), service)
      && contains(keys(var.alarm.threshold), metric_key)
  ]...)
}


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
