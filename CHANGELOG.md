# Changelog

All notable changes to this project will be documented in this file.

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
