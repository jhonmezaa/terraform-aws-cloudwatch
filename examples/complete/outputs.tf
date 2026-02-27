output "log_group_names" {
  description = "Log group names"
  value       = module.cloudwatch.log_group_names
}

output "log_group_arns" {
  description = "Log group ARNs"
  value       = module.cloudwatch.log_group_arns
}

output "metric_filter_ids" {
  description = "Metric filter IDs"
  value       = module.cloudwatch.metric_filter_ids
}

output "metric_alarm_arns" {
  description = "Metric alarm ARNs"
  value       = module.cloudwatch.metric_alarm_arns
}

output "composite_alarm_arns" {
  description = "Composite alarm ARNs"
  value       = module.cloudwatch.composite_alarm_arns
}

output "query_definition_ids" {
  description = "Query definition IDs"
  value       = module.cloudwatch.query_definition_ids
}

output "dashboard_arns" {
  description = "Dashboard ARNs"
  value       = module.cloudwatch.dashboard_arns
}
