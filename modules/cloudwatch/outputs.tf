output "log_group_names" {
  value = [for k, v in local.log_groups : v.full_name]
}

