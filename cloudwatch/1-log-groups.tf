# =============================================================================
# CloudWatch Log Groups
# =============================================================================

resource "aws_cloudwatch_log_group" "this" {
  for_each = { for k, v in var.log_groups : k => v if var.create }

  name              = local.log_group_names[each.key]
  name_prefix       = each.value.name == null && each.value.name_prefix != null ? each.value.name_prefix : null
  retention_in_days = each.value.retention_in_days
  kms_key_id        = each.value.kms_key_id
  skip_destroy      = each.value.skip_destroy
  log_group_class   = each.value.log_group_class

  tags = merge(
    local.common_tags,
    each.value.tags,
    {
      Name      = local.log_group_tag_names[each.key]
      ManagedBy = "Terraform"
    }
  )
}
