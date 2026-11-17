# =============================================================================
# General Configuration Variables
# =============================================================================

variable "create" {
  description = "Whether to create CloudWatch resources."
  type        = bool
  default     = true
}

variable "account_name" {
  description = "Account name for resource naming (e.g., 'prod', 'staging', 'dev')."
  type        = string

  validation {
    condition     = length(var.account_name) > 0 && length(var.account_name) <= 32
    error_message = "account_name debe tener entre 1 y 32 caracteres."
  }

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.account_name))
    error_message = "account_name solo puede contener letras minúsculas, números y guiones."
  }
}

variable "project_name" {
  description = "Project name for resource naming."
  type        = string

  validation {
    condition     = length(var.project_name) > 0 && length(var.project_name) <= 32
    error_message = "project_name debe tener entre 1 y 32 caracteres."
  }

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "project_name solo puede contener letras minúsculas, números y guiones."
  }
}

variable "region_prefix" {
  description = "Region prefix for naming. If not provided, will be derived from the current region."
  type        = string
  default     = null
}

variable "use_region_prefix" {
  description = "Whether to include the region prefix in resource names."
  type        = bool
  default     = true
}

variable "tags_common" {
  description = "Common tags applied to all taggable CloudWatch resources (merged with per-resource tags, Name and ManagedBy)."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "DEPRECATED: use tags_common. Still merged after tags_common for backward compatibility."
  type        = map(string)
  default     = {}
}

# =============================================================================
# Log Groups
# =============================================================================

variable "log_groups" {
  description = <<-EOT
    Map of CloudWatch Log Group configurations.
    Key is used as identifier in naming: /aws/{account_name}/{project_name}/{key}

    Attributes:
      - name:              (Optional) Override the auto-generated log group name.
      - name_prefix:       (Optional) Creates a unique name beginning with this prefix. Conflicts with name.
      - retention_in_days: (Optional) Log retention in days. Default: 30. Valid values: 0,1,3,5,7,14,30,60,90,120,150,180,365,400,545,731,1096,1827,2192,2557,2922,3288,3653.
      - kms_key_id:        (Optional) ARN of KMS key for encryption.
      - skip_destroy:      (Optional) Keep log group on terraform destroy. Default: false.
      - log_group_class:   (Optional) STANDARD or INFREQUENT_ACCESS. Default: STANDARD.
      - tags:              (Optional) Additional tags for this log group.
  EOT
  type = map(object({
    name              = optional(string)
    name_prefix       = optional(string)
    retention_in_days = optional(number, 30)
    kms_key_id        = optional(string)
    skip_destroy      = optional(bool, false)
    log_group_class   = optional(string, "STANDARD")
    tags              = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.log_groups :
      v.retention_in_days == null ? true : contains(
        [0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653],
        v.retention_in_days
      )
    ])
    error_message = "retention_in_days debe ser uno de: 0,1,3,5,7,14,30,60,90,120,150,180,365,400,545,731,1096,1827,2192,2557,2922,3288,3653."
  }

  validation {
    condition = alltrue([
      for k, v in var.log_groups :
      v.log_group_class == null ? true : contains(["STANDARD", "INFREQUENT_ACCESS"], v.log_group_class)
    ])
    error_message = "log_group_class debe ser STANDARD o INFREQUENT_ACCESS."
  }

  validation {
    condition     = alltrue([for k, v in var.log_groups : !(v.name != null && v.name_prefix != null)])
    error_message = "name y name_prefix son excluyentes en log_groups."
  }
}

# =============================================================================
# Metric Filters
# =============================================================================

variable "metric_filters" {
  description = <<-EOT
    Map of CloudWatch Metric Filter configurations.

    Attributes:
      - log_group_key:    (Optional) Key from log_groups map to reference a log group created by this module.
      - log_group_name:   (Optional) Name of an external log group. Required if log_group_key is not set.
      - filter_pattern:   (Required) CloudWatch Logs filter pattern.
      - metric_transformation: (Required) Metric transformation configuration:
        - name:           (Required) Name of the CloudWatch metric.
        - namespace:      (Required) Destination namespace of the metric.
        - value:          (Optional) Value to publish. Default: "1".
        - default_value:  (Optional) Value when filter pattern does not match. Conflicts with dimensions.
        - dimensions:     (Optional) Additional dimensions. Conflicts with default_value.
        - unit:           (Optional) Unit of the metric.
  EOT
  type = map(object({
    log_group_key  = optional(string)
    log_group_name = optional(string)
    filter_pattern = string
    metric_transformation = object({
      name          = string
      namespace     = string
      value         = optional(string, "1")
      default_value = optional(string)
      dimensions    = optional(map(string), {})
      unit          = optional(string)
    })
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.metric_filters : v.log_group_key != null || v.log_group_name != null
    ])
    error_message = "Cada metric_filter debe definir log_group_key o log_group_name (si se definen ambos, prevalece log_group_key)."
  }
}

# =============================================================================
# Metric Alarms
# =============================================================================

variable "metric_alarms" {
  description = <<-EOT
    Map of CloudWatch Metric Alarm configurations.

    Attributes:
      - alarm_name:          (Optional) Override auto-generated alarm name.
      - alarm_description:   (Optional) Description for the alarm.
      - comparison_operator: (Required) GreaterThanOrEqualToThreshold, GreaterThanThreshold, LessThanThreshold, LessThanOrEqualToThreshold, LessThanLowerOrGreaterThanUpperThreshold, LessThanLowerThreshold, GreaterThanUpperThreshold.
      - evaluation_periods:  (Required) Number of periods over which data is compared.
      - threshold:           (Optional) Value to compare against.
      - threshold_metric_id: (Optional) For anomaly detection, matches the ANOMALY_DETECTION_BAND function ID.
      - metric_name:         (Optional) Metric name. Conflicts with metric_query.
      - namespace:           (Optional) Metric namespace. Conflicts with metric_query.
      - period:              (Optional) Period in seconds.
      - statistic:           (Optional) SampleCount, Average, Sum, Minimum, Maximum.
      - extended_statistic:  (Optional) Percentile statistic (e.g., p99).
      - dimensions:          (Optional) Dimensions for the metric.
      - unit:                (Optional) Unit for the metric.
      - datapoints_to_alarm: (Optional) Datapoints that must breach to trigger alarm.
      - treat_missing_data:  (Optional) missing, ignore, breaching, notBreaching. Default: missing.
      - evaluate_low_sample_count_percentiles: (Optional) ignore or evaluate.
      - actions_enabled:     (Optional) Execute actions on state change. Default: true.
      - alarm_actions:       (Optional) List of ARNs for ALARM state.
      - ok_actions:          (Optional) List of ARNs for OK state.
      - insufficient_data_actions: (Optional) List of ARNs for INSUFFICIENT_DATA state.
      - metric_query:        (Optional) Metric math expressions (up to 20).
      - tags:                (Optional) Additional tags for this alarm.
  EOT
  type = map(object({
    alarm_name                            = optional(string)
    alarm_description                     = optional(string)
    comparison_operator                   = string
    evaluation_periods                    = number
    threshold                             = optional(number)
    threshold_metric_id                   = optional(string)
    metric_name                           = optional(string)
    namespace                             = optional(string)
    period                                = optional(number)
    statistic                             = optional(string)
    extended_statistic                    = optional(string)
    dimensions                            = optional(map(string))
    unit                                  = optional(string)
    datapoints_to_alarm                   = optional(number)
    treat_missing_data                    = optional(string, "missing")
    evaluate_low_sample_count_percentiles = optional(string)
    actions_enabled                       = optional(bool, true)
    alarm_actions                         = optional(list(string))
    ok_actions                            = optional(list(string))
    insufficient_data_actions             = optional(list(string))
    metric_query = optional(list(object({
      id          = string
      account_id  = optional(string)
      label       = optional(string)
      return_data = optional(bool)
      expression  = optional(string)
      period      = optional(number)
      metric = optional(list(object({
        metric_name = string
        namespace   = string
        period      = number
        stat        = string
        unit        = optional(string)
        dimensions  = optional(map(string))
      })), [])
    })), [])
    tags = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.metric_alarms : contains([
        "GreaterThanOrEqualToThreshold", "GreaterThanThreshold", "LessThanThreshold", "LessThanOrEqualToThreshold",
        "LessThanLowerOrGreaterThanUpperThreshold", "LessThanLowerThreshold", "GreaterThanUpperThreshold",
      ], v.comparison_operator)
    ])
    error_message = "comparison_operator no es válido. Valores: GreaterThanOrEqualToThreshold, GreaterThanThreshold, LessThanThreshold, LessThanOrEqualToThreshold, LessThanLowerOrGreaterThanUpperThreshold, LessThanLowerThreshold, GreaterThanUpperThreshold."
  }

  validation {
    condition = alltrue([
      for k, v in var.metric_alarms : v.treat_missing_data == null ? true : contains(["missing", "ignore", "breaching", "notBreaching"], v.treat_missing_data)
    ])
    error_message = "treat_missing_data debe ser missing, ignore, breaching o notBreaching."
  }

  validation {
    condition = alltrue([
      for k, v in var.metric_alarms : !(v.metric_name != null && length(v.metric_query) > 0)
    ])
    error_message = "metric_name y metric_query son excluyentes en metric_alarms."
  }

  validation {
    condition = alltrue([
      for k, v in var.metric_alarms : !(v.statistic != null && v.extended_statistic != null)
    ])
    error_message = "statistic y extended_statistic son excluyentes en metric_alarms."
  }
}

# =============================================================================
# Composite Alarms
# =============================================================================

variable "composite_alarms" {
  description = <<-EOT
    Map of CloudWatch Composite Alarm configurations.

    Attributes:
      - alarm_name:          (Optional) Override auto-generated alarm name.
      - alarm_description:   (Optional) Description for the composite alarm.
      - alarm_rule:          (Optional) Expression specifying which alarms to evaluate (raw string with full alarm ARNs/names).
      - metric_alarm_keys:   (Optional) List of metric alarm keys from this module to auto-build the alarm rule.
      - metric_alarm_keys_operator: (Optional) Logical operator for auto-built rule: "AND" or "OR". Default: "AND".
      NOTE: Provide either alarm_rule OR metric_alarm_keys, not both.
      - actions_enabled:     (Optional) Execute actions on state change. Default: true.
      - alarm_actions:       (Optional) List of ARNs for ALARM state (up to 5).
      - ok_actions:          (Optional) List of ARNs for OK state (up to 5).
      - insufficient_data_actions: (Optional) List of ARNs for INSUFFICIENT_DATA state (up to 5).
      - actions_suppressor:  (Optional) Actions suppressor configuration:
        - alarm:             (Required) ARN of the suppressor alarm.
        - extension_period:  (Required) Maximum suppression time after suppressor leaves ALARM.
        - wait_period:       (Required) Maximum wait time for suppressor to go into ALARM.
      - tags:                (Optional) Additional tags for this composite alarm.
  EOT
  type = map(object({
    alarm_name                 = optional(string)
    alarm_description          = optional(string)
    alarm_rule                 = optional(string)
    metric_alarm_keys          = optional(list(string), [])
    metric_alarm_keys_operator = optional(string, "AND")
    actions_enabled            = optional(bool, true)
    alarm_actions              = optional(list(string))
    ok_actions                 = optional(list(string))
    insufficient_data_actions  = optional(list(string))
    actions_suppressor = optional(object({
      alarm            = string
      extension_period = number
      wait_period      = number
    }))
    tags = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.composite_alarms : (v.alarm_rule != null) != (length(v.metric_alarm_keys) > 0)
    ])
    error_message = "Cada composite_alarm debe definir exactamente uno de alarm_rule o metric_alarm_keys."
  }

  validation {
    condition = alltrue([
      for k, v in var.composite_alarms : contains(["AND", "OR"], v.metric_alarm_keys_operator)
    ])
    error_message = "metric_alarm_keys_operator debe ser AND u OR."
  }
}

# =============================================================================
# Subscription Filters
# =============================================================================

variable "subscription_filters" {
  description = <<-EOT
    Map of CloudWatch Log Subscription Filter configurations.

    Attributes:
      - log_group_key:    (Optional) Key from log_groups map to reference a log group created by this module.
      - log_group_name:   (Optional) Name of an external log group. Required if log_group_key is not set.
      - destination_arn:  (Required) ARN of the destination (Lambda, Kinesis, Firehose, or OpenSearch).
      - filter_pattern:   (Optional) CloudWatch Logs filter pattern. Empty string matches everything.
      - role_arn:         (Optional) IAM role ARN for CloudWatch Logs to deliver events to the destination.
      - distribution:     (Optional) Method to distribute log data: Random or ByLogStream (default).
  EOT
  type = map(object({
    log_group_key   = optional(string)
    log_group_name  = optional(string)
    destination_arn = string
    filter_pattern  = optional(string, "")
    role_arn        = optional(string)
    distribution    = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.subscription_filters : v.log_group_key != null || v.log_group_name != null
    ])
    error_message = "Cada subscription_filter debe definir log_group_key o log_group_name (si se definen ambos, prevalece log_group_key)."
  }

  validation {
    condition = alltrue([
      for k, v in var.subscription_filters : v.distribution == null ? true : contains(["Random", "ByLogStream"], v.distribution)
    ])
    error_message = "distribution debe ser Random o ByLogStream."
  }
}

# =============================================================================
# Query Definitions
# =============================================================================

variable "query_definitions" {
  description = <<-EOT
    Map of CloudWatch Insights Query Definition configurations.

    Attributes:
      - name:            (Optional) Name of the query. Default: {region_prefix}-cw-query-{account_name}-{project_name}-{key}.
      - query_string:    (Required) The query string for CloudWatch Logs Insights.
      - log_group_names: (Optional) List of log group names to associate with the query.
  EOT
  type = map(object({
    name            = optional(string)
    query_string    = string
    log_group_names = optional(list(string))
  }))
  default = {}
}

# =============================================================================
# Dashboards
# =============================================================================

variable "dashboards" {
  description = <<-EOT
    Map of CloudWatch Dashboard configurations.

    Attributes:
      - dashboard_name: (Optional) Override auto-generated dashboard name.
      - dashboard_body: (Required) JSON string for the dashboard body layout.
  EOT
  type = map(object({
    dashboard_name = optional(string)
    dashboard_body = string
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.dashboards : can(regex("^[A-Za-z0-9_-]+$", coalesce(v.dashboard_name, k)))
    ])
    error_message = "El nombre del dashboard (dashboard_name o la key del mapa) solo puede contener letras, números, guiones y guiones bajos."
  }
}

# =============================================================================
# Log Streams
# =============================================================================

variable "log_streams" {
  description = <<-EOT
    Map of CloudWatch Log Stream configurations.

    Attributes:
      - name:           (Optional) Log stream name. Default: the map key.
      - log_group_key:  (Optional) Key from log_groups map to reference a log group created by this module.
      - log_group_name: (Optional) Name of an external log group. Required if log_group_key is not set.
  EOT
  type = map(object({
    name           = optional(string)
    log_group_key  = optional(string)
    log_group_name = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.log_streams : (v.log_group_key == null) != (v.log_group_name == null)
    ])
    error_message = "Cada log_stream debe definir exactamente uno de log_group_key o log_group_name."
  }
}
