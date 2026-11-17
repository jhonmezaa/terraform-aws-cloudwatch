# =============================================================================
# CloudWatch Log Streams
# =============================================================================

resource "aws_cloudwatch_log_stream" "this" {
  for_each = { for k, v in var.log_streams : k => v if var.create }

  name           = each.value.name != null ? each.value.name : each.key
  log_group_name = local.log_streams_resolved[each.key].resolved_log_group_name

  lifecycle {
    precondition {
      condition     = each.value.log_group_key == null || contains(keys(var.log_groups), coalesce(each.value.log_group_key, "-"))
      error_message = "log_group_key \"${coalesce(each.value.log_group_key, "-")}\" no existe en var.log_groups."
    }
  }
}
