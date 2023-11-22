variable "prefix" {
  type        = string
  description = "This prefix will be included in the name of most resources."
  validation {
    condition = can(regex("^[a-z0-9][a-z0-9\\.\\-]+$", var.prefix))
    error_message = "S3 bucket names can only contain lowecase letters, numbers, hyphens, or dots."
  }
}

variable "region" {
  type        = string
  description = "The region where the resources are created."
}

variable "env" {
  type        = string
  description = "Value for the environment tag."
  validation {
    condition     = contains(["dev", "test", "prod", "demo"], var.env)
    error_message = "Environment must be one of: dev, test, prod, demo."
  }
}

variable "department" {
  type        = string
  description = "Value for the department tag."
  default     = "WebDev"
}

variable "expired_version_retention_days" {
  type        = number
  description = "Number of days to retain expired versions."
  validation {
    condition     = var.expired_version_retention_days > 0 && var.expired_version_retention_days <= 365
    error_message = "Please choose a value between 1 and 365 days."
  }
}
