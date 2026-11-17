variable "aws_region" {
  description = "AWS region where the example resources are created."
  type        = string
  default     = "us-east-1"
}

variable "account_name" {
  description = "Account name used for resource naming."
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name used for resource naming."
  type        = string
  default     = "myapp"
}
