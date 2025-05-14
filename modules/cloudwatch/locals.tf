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

  nested_log_groups = {
    for env in keys(var.logs.log_group_prefix) :
    env => {
      for log_key, base_path in var.logs.group_paths :
      "${env}_${log_key}" => {
        full_name = "${base_path}-${var.logs.log_group_prefix[env]}"
      }
    }
  }

  log_groups = merge(
    values(local.nested_log_groups)...
  )
}
