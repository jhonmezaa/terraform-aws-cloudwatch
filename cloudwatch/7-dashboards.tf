# =============================================================================
# CloudWatch Dashboards
# =============================================================================

resource "aws_cloudwatch_dashboard" "this" {
  for_each = { for k, v in var.dashboards : k => v if var.create }

  dashboard_name = each.value.dashboard_name != null ? each.value.dashboard_name : (
    "${local.name_prefix}cw-dash-${var.account_name}-${var.project_name}-${each.key}"
  )
  dashboard_body = each.value.dashboard_body
}
