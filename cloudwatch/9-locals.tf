locals {
  # =============================================================================
  # Region Prefix Mapping
  # =============================================================================

  region_prefix_map = {
    # US Regions
    "us-east-1" = "ause1"
    "us-east-2" = "ause2"
    "us-west-1" = "ausw1"
    "us-west-2" = "ausw2"
    # EU Regions
    "eu-west-1"    = "euwe1"
    "eu-west-2"    = "euwe2"
    "eu-west-3"    = "euwe3"
    "eu-central-1" = "euce1"
    "eu-central-2" = "euce2"
    "eu-north-1"   = "euno1"
    "eu-south-1"   = "euso1"
    "eu-south-2"   = "euso2"
    # AP Regions
    "ap-southeast-1" = "apse1"
    "ap-southeast-2" = "apse2"
    "ap-southeast-3" = "apse3"
    "ap-southeast-4" = "apse4"
    "ap-northeast-1" = "apne1"
    "ap-northeast-2" = "apne2"
    "ap-northeast-3" = "apne3"
    "ap-south-1"     = "apso1"
    "ap-south-2"     = "apso2"
    "ap-east-1"      = "apea1"
    # SA Regions
    "sa-east-1" = "saea1"
    # CA Regions
    "ca-central-1" = "cace1"
    "ca-west-1"    = "cawe1"
    # ME Regions
    "me-south-1"   = "meso1"
    "me-central-1" = "mece1"
    # AF Regions
    "af-south-1" = "afso1"
    # IL Regions
    "il-central-1" = "ilce1"
  }

  region_prefix = var.region_prefix != null ? var.region_prefix : lookup(
    local.region_prefix_map,
    data.aws_region.current.id,
    data.aws_region.current.id
  )

  # Name prefix: includes region prefix with trailing dash, or empty string
  name_prefix = var.use_region_prefix ? "${local.region_prefix}-" : ""

  # =============================================================================
  # Log Group Name Generation
  # =============================================================================

  log_group_names = {
    for key, lg in var.log_groups : key => (
      lg.name != null ? lg.name : (
        lg.name_prefix != null ? null : "/aws/${var.account_name}/${var.project_name}/${key}"
      )
    )
  }

  # =============================================================================
  # Metric Filter - Resolve log group references
  # =============================================================================

  metric_filters_resolved = {
    for key, mf in var.metric_filters : key => merge(mf, {
      resolved_log_group_name = (
        mf.log_group_key != null
        ? try(aws_cloudwatch_log_group.this[mf.log_group_key].name, "")
        : mf.log_group_name
      )
    })
  }

  # =============================================================================
  # Subscription Filter - Resolve log group references
  # =============================================================================

  subscription_filters_resolved = {
    for key, sf in var.subscription_filters : key => merge(sf, {
      resolved_log_group_name = (
        sf.log_group_key != null
        ? try(aws_cloudwatch_log_group.this[sf.log_group_key].name, "")
        : sf.log_group_name
      )
    })
  }
}
