# =============================================================================
# CloudWatch Log Subscription Filters
# =============================================================================

resource "aws_cloudwatch_log_subscription_filter" "this" {
  for_each = { for k, v in var.subscription_filters : k => v if var.create }

  name            = each.key
  destination_arn = each.value.destination_arn
  filter_pattern  = each.value.filter_pattern
  log_group_name  = local.subscription_filters_resolved[each.key].resolved_log_group_name
  role_arn        = each.value.role_arn
  distribution    = each.value.distribution
}
