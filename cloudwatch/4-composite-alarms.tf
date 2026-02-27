# =============================================================================
# CloudWatch Composite Alarms
# =============================================================================

resource "aws_cloudwatch_composite_alarm" "this" {
  for_each = { for k, v in var.composite_alarms : k => v if var.create }

  alarm_name = each.value.alarm_name != null ? each.value.alarm_name : (
    "${local.name_prefix}cw-composite-${var.account_name}-${var.project_name}-${each.key}"
  )
  alarm_description = each.value.alarm_description
  actions_enabled   = each.value.actions_enabled

  alarm_actions             = each.value.alarm_actions
  ok_actions                = each.value.ok_actions
  insufficient_data_actions = each.value.insufficient_data_actions
  alarm_rule                = each.value.alarm_rule

  dynamic "actions_suppressor" {
    for_each = each.value.actions_suppressor != null ? [each.value.actions_suppressor] : []

    content {
      alarm            = actions_suppressor.value.alarm
      extension_period = actions_suppressor.value.extension_period
      wait_period      = actions_suppressor.value.wait_period
    }
  }

  tags = merge(
    var.tags,
    each.value.tags,
  )
}
