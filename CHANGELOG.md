# Changelog

All notable changes to this project will be documented in this file.

## [v1.2.0] - 2026-11-17

### Added

- `tags_common` variable, merged into every taggable resource (log groups, metric alarms, composite alarms)
- `Name` and `ManagedBy = "Terraform"` tags on metric alarms and composite alarms, and `ManagedBy` on log groups
- `log_streams` map (`aws_cloudwatch_log_stream`) with `log_group_key` / `log_group_name` resolution, plus `log_stream_names` and `log_stream_arns` outputs
- `dashboard_names` output
- Default name for query definitions (`{region_prefix}-cw-query-{account_name}-{project_name}-{key}`); `query_definitions[*].name` is now optional
- Plan-time validations: `name`/`name_prefix` conflict in log groups, missing log group in metric/subscription filters, unknown `log_group_key` (preconditions), `alarm_rule` vs `metric_alarm_keys` in composite alarms, unknown `metric_alarm_keys`, `metric_alarm_keys_operator`, `comparison_operator`, `treat_missing_data`, `metric_name` vs `metric_query`, `statistic` vs `extended_statistic`, subscription `distribution`, and dashboard name characters
- `variables.tf` and `README.md` for the `basic` and `complete` examples

### Changed

- Validation error messages for `account_name` and `project_name` are now in Spanish, per project convention
- The log group `Name` tag uses `name_prefix` when the group is created with a prefix (it previously showed the unused `/aws/...` default)
- Module files renumbered to keep resources before data/locals/variables/outputs (`8-log-streams.tf`, `9-data.tf`, `10-locals.tf`, `11-variables.tf`, `12-outputs.tf`)
- `complete` example builds its composite alarm with `metric_alarm_keys` instead of reading the module's own outputs
- README: `source` refs point to `v1.2.0`; documented tags, validations, log streams and the full naming table

### Fixed

- A `log_group_key` that does not exist in `log_groups` no longer resolves silently to an empty log group name (failing only at apply); it now fails at plan
- A composite alarm with neither `alarm_rule` nor `metric_alarm_keys` no longer produces an empty `alarm_rule`

### Deprecated

- `tags`: use `tags_common`. Both are merged (`tags` after `tags_common`) so existing configurations keep working

### Upgrade notes

- No resource is recreated. The first plan shows in-place tag updates: `ManagedBy = "Terraform"` on log groups and `Name`/`ManagedBy` on metric and composite alarms
- Removed the unused `aws_caller_identity` and `aws_partition` data sources (no state impact on managed resources)
- Configurations that set both `alarm_rule` and `metric_alarm_keys` on a composite alarm (previously `alarm_rule` silently won), or set both `name` and `name_prefix` on a log group, now fail validation; keep only one

## [v1.1.5] - 2026-10-27

### Changed

- Normalize CHANGELOG format: preamble moved to the top, all headings use `## [vX.Y.Z] - YYYY-MM-DD`, entries sorted by version (newest first)
- Add missing CHANGELOG entries for v1.1.0 and v1.1.1, reconstructed from git history

## [v1.1.4] - 2026-10-27

### Fixed

- Replace deprecated `data.aws_region.current.id` with `data.aws_region.current.region` (AWS provider v6)

## [v1.1.3] - 2026-10-27

### Changed

- Use minimum-only version constraints in the reusable module, per HashiCorp guidance: AWS provider `~> 6.0` -> `>= 6.0`
- Set module `required_version` to `>= 1.3` (was `~> 1.0`), the real minimum required by the use of `optional()` object attributes in variable types (Terraform 1.3+)
- Examples (root modules) keep pessimistic constraints: `required_version` `~> 1.3` and AWS provider `~> 6.0`
- Update README requirements table

## [v1.1.2] - 2026-04-25

### Changed

- Update README documentation and CHANGELOG formatting

## [v1.1.1] - 2026-02-28

### Changed

- Update README documentation

## [v1.1.0] - 2026-02-27

### Added

- `metric_alarm_keys` support for composite alarms: reference metric alarms created in the same module instead of hardcoded alarm names/ARNs; the module builds `alarm_rule` from the referenced metric alarm ARNs
- `metric_alarm_keys_operator` (`AND`/`OR`, default `AND`) to combine the referenced alarms

### Changed

- `alarm_rule` in `composite_alarms` is now optional (provide either `alarm_rule` or `metric_alarm_keys`)

## [v1.0.0] - 2026-02-27

### Added

- CloudWatch Log Groups with configurable retention, encryption, and log group class (STANDARD/INFREQUENT_ACCESS).
- CloudWatch Metric Filters with metric transformation support including dimensions and default values.
- CloudWatch Metric Alarms with support for simple metrics, anomaly detection, and math expressions.
- CloudWatch Composite Alarms with alarm rule expressions and actions suppressor support.
- CloudWatch Log Subscription Filters for Lambda, Kinesis, Firehose, and OpenSearch destinations.
- CloudWatch Insights Query Definitions for reusable log queries.
- CloudWatch Dashboards with JSON body configuration.
- Unified naming convention with region prefix support (29 AWS regions).
- Cross-resource referencing via `log_group_key` for metric filters and subscription filters.
- Basic and complete examples demonstrating all features.
