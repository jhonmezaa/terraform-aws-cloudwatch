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
  alarm_rule = each.value.alarm_rule != null ? each.value.alarm_rule : join(
    " ${each.value.metric_alarm_keys_operator} ",
    [for key in each.value.metric_alarm_keys : "ALARM(\"${try(aws_cloudwatch_metric_alarm.this[key].arn, key)}\")"]
  )

  dynamic "actions_suppressor" {
    for_each = each.value.actions_suppressor != null ? [each.value.actions_suppressor] : []

    content {
      alarm            = actions_suppressor.value.alarm
      extension_period = actions_suppressor.value.extension_period
      wait_period      = actions_suppressor.value.wait_period
    }
  }

  tags = merge(
    local.common_tags,
    each.value.tags,
    {
      Name = each.value.alarm_name != null ? each.value.alarm_name : (
        "${local.name_prefix}cw-composite-${var.account_name}-${var.project_name}-${each.key}"
      )
      ManagedBy = "Terraform"
    }
  )

  lifecycle {
    precondition {
      condition     = alltrue([for key in each.value.metric_alarm_keys : contains(keys(var.metric_alarms), key)])
      error_message = "Todas las metric_alarm_keys deben existir en var.metric_alarms."
    }
  }
}
