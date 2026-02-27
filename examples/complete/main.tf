provider "aws" {
  region = "us-east-1"
}

# =============================================================================
# SNS Topic for alarm notifications
# =============================================================================

resource "aws_sns_topic" "alerts" {
  name = "cloudwatch-alerts"
}

# =============================================================================
# CloudWatch Module - Complete Example
# =============================================================================

module "cloudwatch" {
  source = "../../cloudwatch"

  account_name = "prod"
  project_name = "ecommerce"

  # =============================================================================
  # Log Groups
  # =============================================================================

  log_groups = {
    application = {
      retention_in_days = 90
      log_group_class   = "STANDARD"
      tags = {
        Component = "app"
      }
    }

    api-gateway = {
      retention_in_days = 60
    }

    lambda = {
      name              = "/aws/lambda/ecommerce-processor"
      retention_in_days = 30
    }

    ecs = {
      retention_in_days = 14
      log_group_class   = "INFREQUENT_ACCESS"
    }
  }

  # =============================================================================
  # Metric Filters
  # =============================================================================

  metric_filters = {
    error-count = {
      log_group_key  = "application"
      filter_pattern = "[timestamp, request_id, level = \"ERROR\", ...]"
      metric_transformation = {
        name          = "ApplicationErrorCount"
        namespace     = "Custom/Ecommerce"
        value         = "1"
        default_value = "0"
      }
    }

    latency = {
      log_group_key  = "api-gateway"
      filter_pattern = "[timestamp, request_id, latency > 1000, ...]"
      metric_transformation = {
        name      = "HighLatencyRequests"
        namespace = "Custom/Ecommerce"
        value     = "1"
      }
    }
  }

  # =============================================================================
  # Metric Alarms
  # =============================================================================

  metric_alarms = {
    high-error-rate = {
      alarm_description   = "Application error rate exceeds threshold"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      evaluation_periods  = 3
      metric_name         = "ApplicationErrorCount"
      namespace           = "Custom/Ecommerce"
      period              = 300
      statistic           = "Sum"
      threshold           = 10
      treat_missing_data  = "notBreaching"
      datapoints_to_alarm = 2
      alarm_actions       = [aws_sns_topic.alerts.arn]
      ok_actions          = [aws_sns_topic.alerts.arn]
    }

    high-cpu = {
      alarm_description   = "EC2 CPU utilization exceeds 90%"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      evaluation_periods  = 2
      metric_name         = "CPUUtilization"
      namespace           = "AWS/EC2"
      period              = 300
      statistic           = "Average"
      threshold           = 90
      alarm_actions       = [aws_sns_topic.alerts.arn]
      dimensions = {
        InstanceId = "i-0123456789abcdef0"
      }
    }

    math-expression = {
      alarm_description   = "Error rate percentage exceeds 5%"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      evaluation_periods  = 2
      threshold           = 5

      metric_query = [
        {
          id          = "error_rate"
          expression  = "errors / requests * 100"
          label       = "Error Rate %"
          return_data = true
        },
        {
          id = "errors"
          metric = [{
            metric_name = "5XXError"
            namespace   = "AWS/ApiGateway"
            period      = 300
            stat        = "Sum"
            dimensions = {
              ApiName = "ecommerce-api"
            }
          }]
        },
        {
          id = "requests"
          metric = [{
            metric_name = "Count"
            namespace   = "AWS/ApiGateway"
            period      = 300
            stat        = "Sum"
            dimensions = {
              ApiName = "ecommerce-api"
            }
          }]
        }
      ]

      alarm_actions = [aws_sns_topic.alerts.arn]
    }
  }

  # =============================================================================
  # Composite Alarms
  # =============================================================================

  composite_alarms = {
    service-health = {
      alarm_description = "Composite alarm: service unhealthy when both CPU and error rate are high"
      alarm_rule        = "ALARM(\"${module.cloudwatch.metric_alarm_arns["high-error-rate"]}\") AND ALARM(\"${module.cloudwatch.metric_alarm_arns["high-cpu"]}\")"
      alarm_actions     = [aws_sns_topic.alerts.arn]
    }
  }

  # =============================================================================
  # Query Definitions
  # =============================================================================

  query_definitions = {
    top-errors = {
      name         = "TopErrors"
      query_string = "fields @timestamp, @message | filter @message like /ERROR/ | stats count(*) as errorCount by @message | sort errorCount desc | limit 20"
      log_group_names = [
        "/aws/prod/ecommerce/application"
      ]
    }

    slow-requests = {
      name         = "SlowRequests"
      query_string = "fields @timestamp, @message, latency | filter latency > 1000 | sort latency desc | limit 50"
    }
  }

  # =============================================================================
  # Dashboards
  # =============================================================================

  dashboards = {
    operations = {
      dashboard_body = jsonencode({
        widgets = [
          {
            type   = "metric"
            x      = 0
            y      = 0
            width  = 12
            height = 6
            properties = {
              metrics = [
                ["Custom/Ecommerce", "ApplicationErrorCount", { stat = "Sum", period = 300 }]
              ]
              title  = "Application Errors"
              region = "us-east-1"
            }
          },
          {
            type   = "metric"
            x      = 12
            y      = 0
            width  = 12
            height = 6
            properties = {
              metrics = [
                ["AWS/EC2", "CPUUtilization", "InstanceId", "i-0123456789abcdef0"]
              ]
              title  = "EC2 CPU Utilization"
              region = "us-east-1"
            }
          }
        ]
      })
    }
  }

  tags = {
    Environment = "prod"
    Team        = "platform"
    Terraform   = "true"
  }
}
