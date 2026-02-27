# =============================================================================
# Log Group Outputs
# =============================================================================

output "log_group_names" {
  description = "Map of log group keys to their names."
  value = {
    for k, v in aws_cloudwatch_log_group.this : k => v.name
  }
}

output "log_group_arns" {
  description = "Map of log group keys to their ARNs."
  value = {
    for k, v in aws_cloudwatch_log_group.this : k => v.arn
  }
}

# =============================================================================
# Metric Filter Outputs
# =============================================================================

output "metric_filter_ids" {
  description = "Map of metric filter keys to their IDs."
  value = {
    for k, v in aws_cloudwatch_log_metric_filter.this : k => v.id
  }
}

# =============================================================================
# Metric Alarm Outputs
# =============================================================================

output "metric_alarm_arns" {
  description = "Map of metric alarm keys to their ARNs."
  value = {
    for k, v in aws_cloudwatch_metric_alarm.this : k => v.arn
  }
}

output "metric_alarm_ids" {
  description = "Map of metric alarm keys to their IDs."
  value = {
    for k, v in aws_cloudwatch_metric_alarm.this : k => v.id
  }
}

# =============================================================================
# Composite Alarm Outputs
# =============================================================================

output "composite_alarm_arns" {
  description = "Map of composite alarm keys to their ARNs."
  value = {
    for k, v in aws_cloudwatch_composite_alarm.this : k => v.arn
  }
}

output "composite_alarm_ids" {
  description = "Map of composite alarm keys to their IDs."
  value = {
    for k, v in aws_cloudwatch_composite_alarm.this : k => v.id
  }
}

# =============================================================================
# Subscription Filter Outputs
# =============================================================================

output "subscription_filter_names" {
  description = "Map of subscription filter keys to their names."
  value = {
    for k, v in aws_cloudwatch_log_subscription_filter.this : k => v.name
  }
}

# =============================================================================
# Query Definition Outputs
# =============================================================================

output "query_definition_ids" {
  description = "Map of query definition keys to their IDs."
  value = {
    for k, v in aws_cloudwatch_query_definition.this : k => v.query_definition_id
  }
}

# =============================================================================
# Dashboard Outputs
# =============================================================================

output "dashboard_arns" {
  description = "Map of dashboard keys to their ARNs."
  value = {
    for k, v in aws_cloudwatch_dashboard.this : k => v.dashboard_arn
  }
}
