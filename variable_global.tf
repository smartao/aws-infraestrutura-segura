# =============================================================================
# Global Configuration
# =============================================================================
variable "region" {
  description = "AWS region"
  type        = string

  validation {
    condition = contains([
      "us-east-1",
      "us-east-2",
      "us-west-1",
      "us-west-2"
    ], var.region)

    error_message = "Invalid AWS region. Allowed regions are: us-east-1, us-east-2, us-west-1, us-west-2."
  }
}

variable "azs" {
  description = "A list of availability zones to use"
  type        = list(string)

  validation {
    condition     = length(var.azs) >= 2
    error_message = "At least two Availability Zones must be specified for high availability."
  }
}

# =============================================================================
# Tagging Configuration
# =============================================================================
variable "environment" {
  description = "Environment (e.g., dev, stg, prod)"
  type        = string

  validation {
    condition     = contains(["tst", "dev", "stage", "prod"], var.environment)
    error_message = "Invalid environment. Allowed values: tst, dev, stage ou prod."
  }
}

variable "owner" {
  description = "Resource owner"
  type        = string
  validation {
    condition     = length(var.owner) > 2
    error_message = "Owner must contain at least 3 characters."
  }
}

variable "project" {
  description = "Project name"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}