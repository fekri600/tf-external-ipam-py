resource "aws_cloudwatch_dashboard" "combined" {
  count = var.dashboard_config.create_combined_dashboard ? 1 : 0

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

resource "aws_cloudwatch_dashboard" "environment" {
  for_each = var.dashboard_config.create_separate_dashboards ? var.env_configs : {}

  dashboard_name = "${each.key}-dashboard"

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
            markdown = "# ${title(each.key)} Environment Dashboard"
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
        } if split(" ", w.title)[0] == each.key
      ]
    )
  })
}
