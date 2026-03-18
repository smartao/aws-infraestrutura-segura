variable "common_name" {
  description = "The Common Name (CN) for the self-signed certificate (e.g., internal.app.local)"
  type        = string

  validation {
    condition     = length(var.common_name) > 0
    error_message = "VALIDATION: common_name must not be empty."
  }
}

variable "organization" {
  description = "The organization name for the certificate subject"
  type        = string
  default     = "Internal"
}

variable "validity_period_hours" {
  description = "Number of hours the certificate remains valid"
  type        = number
  default     = 8760 # 1 year

  validation {
    condition     = var.validity_period_hours >= 24
    error_message = "VALIDATION: validity_period_hours must be at least 24 hours."
  }
}

variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
}

variable "environment" {
  description = "Environment tag for resources"
  type        = string
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
}
