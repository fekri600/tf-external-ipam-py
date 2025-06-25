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
      if contains(keys(var.alarm.dim), service)
      && contains(keys(var.alarm.attr), service)
      && contains(keys(var.alarm.threshold), metric_key)
    }
  ]...)

  nested_log_groups = {
    for log_key, base_path in var.logs.group_paths :
    "${var.environment}_${log_key}" => {
      full_name = "${base_path}-${var.environment}"
    }
  }

  # Flatten all environment-specific log groups into one map
  log_groups = merge(values(local.nested_log_groups)...)

  # Generate log metric filters for all defined log groups
  log_metric_filters = {
    for key, lg in local.log_groups : key => {
      log_group_name   = lg
      pattern          = var.logs.filters.pattern.error
      metric_name      = "${split("/", lg)[length(split("/", lg)) - 1]}-error"
      metric_namespace = var.logs.filters.transformation.namespace
      metric_value     = var.logs.filters.transformation.value
    }
  }

  # Build specs for the four log‑metric alarms in every environment
  log_alarm_specs = {
    for name, metric in var.alarm.metric :
    "${var.environment}_${name}" => {
      env         = var.environment
      alarm_name  = "${var.environment}-${metric}"
      metric_name = metric
      threshold   = var.alarm.threshold[name]
    }
    if startswith(name, "nginx_")
    || startswith(name, "rds_")
    || startswith(name, "redis_")
    || startswith(name, "app_")
  }
  metric_widgets = flatten([
    for name, spec in local.alarm_specs : [
      for env, cfg in var.env_configs : {
        x         = 0
        y         = 0
        width     = 12
        height    = 6
        type      = "metric"
        namespace = spec.namespace
        metric    = spec.metric
        dim       = spec.dim
        id        = lookup(cfg, spec.attr)
        title     = "${env} ${name}"
        region    = var.aws_region
      }
    ]
  ])
}


