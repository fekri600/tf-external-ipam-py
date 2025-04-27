# modules/cloudwatch/alarms/main.tf
locals {
  alarm_specs = {
    ec2_cpu   = { namespace="AWS/EC2", metric="CPUUtilization", threshold=80, dim="InstanceId", attr="ec2_id" }
    rds_cpu   = { namespace="AWS/RDS", metric="CPUUtilization", threshold=80, dim="DBInstanceIdentifier", attr="rds_id" }
    redis_cpu = { namespace="AWS/ElastiCache", metric="CPUUtilization", threshold=80, dim="CacheClusterId", attr="redis_id" }
  }
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
  for_each = {
    for env, cfg in var.env_configs :
    for name, spec in local.alarm_specs :
    "${env}_${name}" => {
      ns   = spec.namespace
      met  = spec.metric
      thr  = spec.threshold
      dimk = spec.dim
      id   = lookup(cfg, spec.attr)
    }
  }

  alarm_name          = each.key
  namespace           = each.value.ns
  metric_name         = each.value.met
  dimensions          = { (each.value.dimk) = each.value.id }
  threshold           = each.value.thr
  evaluation_periods  = 2
  comparison_operator = "GreaterThanThreshold"
  statistic           = "Average"
  period              = 300
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]
}
