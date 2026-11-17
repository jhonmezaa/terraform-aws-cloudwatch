provider "aws" {
  region = var.aws_region
}

module "cloudwatch" {
  source = "../../cloudwatch"

  account_name = var.account_name
  project_name = var.project_name

  # =============================================================================
  # Log Groups
  # =============================================================================

  log_groups = {
    application = {
      retention_in_days = 14
    }

    api = {
      retention_in_days = 30
    }
  }

  # =============================================================================
  # Metric Alarms
  # =============================================================================

  metric_alarms = {
    high-cpu = {
      comparison_operator = "GreaterThanOrEqualToThreshold"
      evaluation_periods  = 2
      metric_name         = "CPUUtilization"
      namespace           = "AWS/EC2"
      period              = 300
      statistic           = "Average"
      threshold           = 80
      alarm_description   = "EC2 CPU utilization is too high"
      treat_missing_data  = "notBreaching"
    }
  }

  tags_common = {
    Environment = "dev"
    Terraform   = "true"
  }
}
