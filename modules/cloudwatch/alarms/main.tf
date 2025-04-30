# modules/cloudwatch/alarms/main.tf

locals {
  alarm_specs = {
    # EC2 Metrics
    ec2_cpu_high = {
      namespace = "AWS/EC2"
      metric    = "CPUUtilization"
      threshold = 80
      dim       = "AutoScalingGroupName"
      attr      = "asg_name"
    }
    ec2_memory_high = {
      namespace = "AWS/EC2"
      metric    = "MemoryUtilization"
      threshold = 80
      dim       = "AutoScalingGroupName"
      attr      = "asg_name"
    }
    ec2_disk_read_ops_high = {
      namespace = "AWS/EC2"
      metric    = "DiskReadOps"
      threshold = 1000
      dim       = "AutoScalingGroupName"
      attr      = "asg_name"
    }
    ec2_disk_write_ops_high = {
      namespace = "AWS/EC2"
      metric    = "DiskWriteOps"
      threshold = 1000
      dim       = "AutoScalingGroupName"
      attr      = "asg_name"
    }
    ec2_network_in_high = {
      namespace = "AWS/EC2"
      metric    = "NetworkIn"
      threshold = 50000000
      dim       = "AutoScalingGroupName"
      attr      = "asg_name"
    }
    ec2_network_out_high = {
      namespace = "AWS/EC2"
      metric    = "NetworkOut"
      threshold = 50000000
      dim       = "AutoScalingGroupName"
      attr      = "asg_name"
    }

    # RDS Metrics
    rds_cpu_high = {
      namespace = "AWS/RDS"
      metric    = "CPUUtilization"
      threshold = 80
      dim       = "DBInstanceIdentifier"
      attr      = "rds_id"
    }
    rds_free_storage_low = {
      namespace = "AWS/RDS"
      metric    = "FreeStorageSpace"
      threshold = 20000000000
      dim       = "DBInstanceIdentifier"
      attr      = "rds_id"
    }
    rds_freeable_memory_low = {
      namespace = "AWS/RDS"
      metric    = "FreeableMemory"
      threshold = 500000000
      dim       = "DBInstanceIdentifier"
      attr      = "rds_id"
    }
    rds_replica_lag_high = {
      namespace = "AWS/RDS"
      metric    = "ReplicaLag"
      threshold = 60
      dim       = "DBInstanceIdentifier"
      attr      = "rds_id"
    }

    # ElastiCache Redis Metrics
    redis_cpu_high = {
      namespace = "AWS/ElastiCache"
      metric    = "CPUUtilization"
      threshold = 80
      dim       = "CacheClusterId"
      attr      = "redis_id"
    }
    redis_freeable_memory_low = {
      namespace = "AWS/ElastiCache"
      metric    = "FreeableMemory"
      threshold = 50000000
      dim       = "CacheClusterId"
      attr      = "redis_id"
    }
    redis_evictions_high = {
      namespace = "AWS/ElastiCache"
      metric    = "Evictions"
      threshold = 100
      dim       = "CacheClusterId"
      attr      = "redis_id"
    }
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
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = each.value.met
  namespace           = each.value.ns
  period             = 300
  statistic          = "Average"
  threshold          = each.value.thr
  alarm_description  = "Alarm for ${each.key}"
  alarm_actions      = [aws_sns_topic.alerts.arn]

  dimensions = {
    (each.value.dimk) = each.value.id
  }
}



