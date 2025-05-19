locals {
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

resource "aws_cloudwatch_dashboard" "combined" {
  dashboard_name = "combined-dashboard"

  dashboard_body = jsonencode({
    widgets = concat(
      [
        {
          type   = "text"
          x      = 0
          y      = 0
          width  = 24
          height = 1
          properties = {
            markdown = "# Combined CloudWatch Dashboard"
          }
        }
      ],
      [
        for i, w in local.metric_widgets : {
          type   = "metric"
          x      = (i % 2 == 0) ? 0 : 12
          y      = 1 + floor(i / 2) * 6
          width  = 12
          height = 6
          properties = {
            metrics = [[w.namespace, w.metric, w.dim, w.id, { label = w.title }]]
            period  = var.alarm.common_settings.period
            stat    = "Average"
            region  = w.region
            title   = w.title
          }
        }
      ]
    )
  })
}
