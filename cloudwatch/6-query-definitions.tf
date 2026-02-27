# =============================================================================
# CloudWatch Insights Query Definitions
# =============================================================================

resource "aws_cloudwatch_query_definition" "this" {
  for_each = { for k, v in var.query_definitions : k => v if var.create }

  name            = each.value.name
  query_string    = each.value.query_string
  log_group_names = each.value.log_group_names
}
