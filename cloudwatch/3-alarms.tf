# =============================================================================
# CloudWatch Metric Alarms
# =============================================================================

resource "aws_cloudwatch_metric_alarm" "this" {
  for_each = { for k, v in var.metric_alarms : k => v if var.create }

  alarm_name = each.value.alarm_name != null ? each.value.alarm_name : (
    "${local.name_prefix}cw-alarm-${var.account_name}-${var.project_name}-${each.key}"
  )
  alarm_description = each.value.alarm_description
  actions_enabled   = each.value.actions_enabled

  alarm_actions             = each.value.alarm_actions
  ok_actions                = each.value.ok_actions
  insufficient_data_actions = each.value.insufficient_data_actions

  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  threshold           = each.value.threshold
  threshold_metric_id = each.value.threshold_metric_id
  unit                = each.value.unit

  datapoints_to_alarm                   = each.value.datapoints_to_alarm
  treat_missing_data                    = each.value.treat_missing_data
  evaluate_low_sample_count_percentiles = each.value.evaluate_low_sample_count_percentiles

  # Simple metric configuration (conflicts with metric_query)
  metric_name        = each.value.metric_name
  namespace          = each.value.namespace
  period             = each.value.period
  statistic          = each.value.statistic
  extended_statistic = each.value.extended_statistic

  dimensions = each.value.dimensions

  # Metric math expressions (conflicts with metric_name)
  dynamic "metric_query" {
    for_each = each.value.metric_query

    content {
      id          = metric_query.value.id
      account_id  = metric_query.value.account_id
      label       = metric_query.value.label
      return_data = metric_query.value.return_data
      expression  = metric_query.value.expression
      period      = metric_query.value.period

      dynamic "metric" {
        for_each = metric_query.value.metric

        content {
          metric_name = metric.value.metric_name
          namespace   = metric.value.namespace
          period      = metric.value.period
          stat        = metric.value.stat
          unit        = metric.value.unit
          dimensions  = metric.value.dimensions
        }
      }
    }
  }

  tags = merge(
    var.tags,
    each.value.tags,
  )
}
