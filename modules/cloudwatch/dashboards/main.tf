# modules/cloudwatch/dashboards/main.tf
locals {
  widgets = [
    { type="text", x=0,  y=0,  width=24, height=1,  markdown="# Combined Dashboard" },
    { type="metric", x=0,  y=1,  width=12, height=6,  namespace="AWS/EC2",      metric="CPUUtilization",   dim="InstanceId", attr="ec2_id", title="EC2 CPU" },
    { type="metric", x=12, y=1,  width=12, height=6,  namespace="CWAgent",      metric="mem_used_percent", dim="InstanceId", attr="ec2_id", title="EC2 Memory" }
  ]
}

resource "aws_cloudwatch_dashboard" "combined" {
  dashboard_name = "combined-dashboard"
  dashboard_body = jsonencode({
    widgets = [
      for w in local.widgets : merge(
        { type = w.type, x = w.x, y = w.y, width = w.width, height = w.height },
        w.type == "text"
          ? { properties = { markdown = w.markdown } }
          : {
              properties = {
                metrics = [
                  for env, cfg in var.env_configs :
                  [ w.namespace, w.metric, w.dim, lookup(cfg, w.attr), { label = "${env} ${w.title}" } ]
                ],
                period = 300,
                stat   = "Average",
                region = var.aws_region,
                title  = w.title
              }
            }
      )
    ]
  })
}

resource "aws_cloudwatch_dashboard" "env_ec2" {
  for_each      = var.env_configs
  dashboard_name = "${each.key}-ec2-dashboard"
  dashboard_body = <<EOF
{
  "widgets": [
    { "type":"text", "x":0,  "y":0,  "width":24, "height":1, "properties":{"markdown":"# ${each.key} EC2 Dashboard"} },
    { "type":"metric","x":0,"y":1,"width":8,"height":6,"properties":{"metrics":[["AWS/EC2","CPUUtilization","InstanceId","${each.value.ec2_id}"]],"period":300,"stat":"Average","region":"${var.aws_region}","title":"CPU"}}
  ]
}
EOF
}
