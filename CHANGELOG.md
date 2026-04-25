# Changelog


## [v1.1.2] - 2026-04-25

### Changed

- Update README documentation and CHANGELOG formatting

All notable changes to this project will be documented in this file.

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
