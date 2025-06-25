# Create all required CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "this" {
  for_each = local.log_groups

  name              = each.value
  retention_in_days = var.logs.retention_in_days
  tags = {
    VpcId = var.vpc_id
  }
}

# Create CloudWatch Metric Filters with dependency on log groups
resource "aws_cloudwatch_log_metric_filter" "this" {
  for_each = local.log_metric_filters

  # Generate name like "nginx-errors" or "ssm_connectivity-errors"
  name           = "${split("/", each.value.log_group_name)[length(split("/", each.value.log_group_name)) - 1]}-errors"
  pattern        = each.value.pattern
  log_group_name = each.value.log_group_name

  metric_transformation {
    name      = each.value.metric_name
    namespace = each.value.metric_namespace
    value     = each.value.metric_value
  }

  # Ensure log group exists before metric filter
  depends_on = [
    aws_cloudwatch_log_group.this
  ]
}
