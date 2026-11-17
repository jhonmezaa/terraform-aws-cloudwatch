# Complete example

Exercises every feature of the module: log groups (including a name override and `INFREQUENT_ACCESS` class), a log stream, metric filters, simple and metric-math alarms, a composite alarm built from `metric_alarm_keys`, Logs Insights query definitions and a dashboard. An SNS topic is created for alarm notifications.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Inputs

| Name         | Description                     | Type     | Default       |
| ------------ | ------------------------------- | -------- | ------------- |
| aws_region   | AWS region for the example      | `string` | `"us-east-1"` |
| account_name | Account name for resource names | `string` | `"prod"`      |
| project_name | Project name for resource names | `string` | `"ecommerce"` |

## Outputs

| Name                 | Description          |
| -------------------- | -------------------- |
| log_group_names      | Log group names      |
| log_group_arns       | Log group ARNs       |
| log_stream_names     | Log stream names     |
| metric_filter_ids    | Metric filter IDs    |
| metric_alarm_arns    | Metric alarm ARNs    |
| composite_alarm_arns | Composite alarm ARNs |
| query_definition_ids | Query definition IDs |
| dashboard_arns       | Dashboard ARNs       |
| dashboard_names      | Dashboard names      |
