# =============================================================================
# CloudWatch Metric Filters
# =============================================================================

resource "aws_cloudwatch_log_metric_filter" "this" {
  for_each = { for k, v in var.metric_filters : k => v if var.create }

  name           = each.key
  pattern        = each.value.filter_pattern
  log_group_name = local.metric_filters_resolved[each.key].resolved_log_group_name

  metric_transformation {
    name          = each.value.metric_transformation.name
    namespace     = each.value.metric_transformation.namespace
    value         = each.value.metric_transformation.value
    default_value = length(each.value.metric_transformation.dimensions) > 0 ? null : each.value.metric_transformation.default_value
    dimensions    = length(each.value.metric_transformation.dimensions) > 0 ? each.value.metric_transformation.dimensions : null
    unit          = each.value.metric_transformation.unit
  }
}
