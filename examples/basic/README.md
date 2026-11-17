# Basic example

Creates two log groups (`application`, `api`) and one EC2 CPU metric alarm using the module defaults.

Resulting names in `us-east-1` with the default variables:

- `/aws/dev/myapp/application`, `/aws/dev/myapp/api`
- `ause1-cw-alarm-dev-myapp-high-cpu`

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
| account_name | Account name for resource names | `string` | `"dev"`       |
| project_name | Project name for resource names | `string` | `"myapp"`     |

## Outputs

| Name              | Description       |
| ----------------- | ----------------- |
| log_group_names   | Log group names   |
| log_group_arns    | Log group ARNs    |
| metric_alarm_arns | Metric alarm ARNs |
