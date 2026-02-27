# terraform-aws-cloudwatch

Terraform module for AWS CloudWatch - unified module for log groups, metric filters, metric alarms, composite alarms, subscription filters, query definitions, and dashboards.

## Features

- **Log Groups**: Create and manage CloudWatch Log Groups with retention, encryption, and class support.
- **Metric Filters**: Extract metrics from log data using filter patterns.
- **Metric Alarms**: Monitor metrics with threshold, anomaly detection, and math expression support.
- **Composite Alarms**: Combine multiple alarms into composite alarm rules.
- **Subscription Filters**: Stream log data to Lambda, Kinesis, Firehose, or OpenSearch.
- **Query Definitions**: Save CloudWatch Logs Insights queries for reuse.
- **Dashboards**: Create CloudWatch dashboards with custom widgets.

## Usage

### Basic

```hcl
module "cloudwatch" {
  source = "github.com/jhonmezaa/terraform-aws-cloudwatch//cloudwatch?ref=v1.0.0"

  account_name = "prod"
  project_name = "myapp"

  log_groups = {
    application = {
      retention_in_days = 30
    }
  }

  metric_alarms = {
    high-cpu = {
      comparison_operator = "GreaterThanOrEqualToThreshold"
      evaluation_periods  = 2
      metric_name         = "CPUUtilization"
      namespace           = "AWS/EC2"
      period              = 300
      statistic           = "Average"
      threshold           = 80
      alarm_description   = "CPU utilization exceeds 80%"
    }
  }

  tags = {
    Environment = "prod"
    Terraform   = "true"
  }
}
```

### Log Groups with Metric Filters

```hcl
module "cloudwatch" {
  source = "github.com/jhonmezaa/terraform-aws-cloudwatch//cloudwatch?ref=v1.0.0"

  account_name = "prod"
  project_name = "myapp"

  log_groups = {
    application = {
      retention_in_days = 90
      kms_key_id        = "arn:aws:kms:us-east-1:123456789012:key/example"
    }
  }

  metric_filters = {
    error-count = {
      log_group_key  = "application"
      filter_pattern = "[timestamp, request_id, level = \"ERROR\", ...]"
      metric_transformation = {
        name          = "ApplicationErrors"
        namespace     = "Custom/MyApp"
        value         = "1"
        default_value = "0"
      }
    }
  }
}
```

### Math Expression Alarm

```hcl
module "cloudwatch" {
  source = "github.com/jhonmezaa/terraform-aws-cloudwatch//cloudwatch?ref=v1.0.0"

  account_name = "prod"
  project_name = "myapp"

  metric_alarms = {
    error-rate = {
      alarm_description   = "Error rate exceeds 5%"
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
          }]
        },
        {
          id = "requests"
          metric = [{
            metric_name = "Count"
            namespace   = "AWS/ApiGateway"
            period      = 300
            stat        = "Sum"
          }]
        }
      ]
    }
  }
}
```

## Naming Convention

Resources follow the monorepo naming convention:

| Resource | Pattern | Example |
|---|---|---|
| Log Group | `/aws/{account_name}/{project_name}/{key}` | `/aws/prod/myapp/application` |
| Metric Alarm | `{region_prefix}-cw-alarm-{account_name}-{project_name}-{key}` | `ause1-cw-alarm-prod-myapp-high-cpu` |
| Composite Alarm | `{region_prefix}-cw-composite-{account_name}-{project_name}-{key}` | `ause1-cw-composite-prod-myapp-service-health` |
| Dashboard | `{region_prefix}-cw-dash-{account_name}-{project_name}-{key}` | `ause1-cw-dash-prod-myapp-operations` |

All names can be overridden per resource using the `name`, `alarm_name`, or `dashboard_name` attributes.

## Requirements

| Name | Version |
|---|---|
| terraform | ~> 1.0 |
| aws | ~> 6.0 |

## Inputs

| Name | Description | Type | Default | Required |
|---|---|---|---|---|
| account_name | Account name for resource naming | `string` | n/a | yes |
| project_name | Project name for resource naming | `string` | n/a | yes |
| create | Whether to create CloudWatch resources | `bool` | `true` | no |
| region_prefix | Region prefix override | `string` | `null` | no |
| use_region_prefix | Include region prefix in names | `bool` | `true` | no |
| tags | Additional tags for all resources | `map(string)` | `{}` | no |
| log_groups | Map of log group configurations | `map(object)` | `{}` | no |
| metric_filters | Map of metric filter configurations | `map(object)` | `{}` | no |
| metric_alarms | Map of metric alarm configurations | `map(object)` | `{}` | no |
| composite_alarms | Map of composite alarm configurations | `map(object)` | `{}` | no |
| subscription_filters | Map of subscription filter configurations | `map(object)` | `{}` | no |
| query_definitions | Map of query definition configurations | `map(object)` | `{}` | no |
| dashboards | Map of dashboard configurations | `map(object)` | `{}` | no |

## Outputs

| Name | Description |
|---|---|
| log_group_names | Map of log group keys to names |
| log_group_arns | Map of log group keys to ARNs |
| metric_filter_ids | Map of metric filter keys to IDs |
| metric_alarm_arns | Map of metric alarm keys to ARNs |
| metric_alarm_ids | Map of metric alarm keys to IDs |
| composite_alarm_arns | Map of composite alarm keys to ARNs |
| composite_alarm_ids | Map of composite alarm keys to IDs |
| subscription_filter_names | Map of subscription filter keys to names |
| query_definition_ids | Map of query definition keys to IDs |
| dashboard_arns | Map of dashboard keys to ARNs |

## Examples

- [Basic](examples/basic) - Log groups and a simple metric alarm
- [Complete](examples/complete) - All features: log groups, metric filters, alarms, composite alarms, query definitions, and dashboards

## License

MIT Licensed. See [LICENSE](LICENSE) for full details.
