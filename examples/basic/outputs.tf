output "log_group_names" {
  description = "Log group names"
  value       = module.cloudwatch.log_group_names
}

output "log_group_arns" {
  description = "Log group ARNs"
  value       = module.cloudwatch.log_group_arns
}

output "metric_alarm_arns" {
  description = "Metric alarm ARNs"
  value       = module.cloudwatch.metric_alarm_arns
}
