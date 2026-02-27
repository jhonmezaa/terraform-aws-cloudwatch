provider "aws" {
  region = "us-east-1"
}

module "cloudwatch" {
  source = "../../cloudwatch"

  account_name = "dev"
  project_name = "myapp"

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

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
