variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for application instances and internal ALB"
  type        = list(string)
}


variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string

  validation {
    condition     = length(var.name_prefix) <= 32
    error_message = "VALIDATION: name_prefix must be <= 32 characters."
  }
}


variable "listener_port" {
  description = "The port on which the ALB listener accepts connections"
  type        = number
  validation {
    condition     = var.listener_port > 0 && var.listener_port < 65536
    error_message = "VALIDATION: listener_port must be between 1 and 65535."
  }
}

variable "target_group_port" {
  description = "The port on which the application targets receive traffic"
  type        = number
  validation {
    condition     = var.target_group_port > 0 && var.target_group_port < 65536
    error_message = "VALIDATION: target_group_port must be between 1 and 65535."
  }
}

variable "app_protocol" {
  description = "The protocol used by the application (e.g., HTTP, HTTPS)"
  type        = string

  validation {
    condition     = contains(["HTTP", "HTTPS"], var.app_protocol)
    error_message = "VALIDATION: Application protocol must be either HTTP or HTTPS."
  }
}

variable "health_check_path" {
  description = "The destination for the health check request"
  type        = string
  default     = "/"

  validation {
    condition     = can(regex("^/", var.health_check_path))
    error_message = "VALIDATION: health_check_path must start with '/'."
  }
}

variable "health_check_matcher" {
  description = "The HTTP codes to use when checking for a successful response"
  type        = string
  default     = "200"

  validation {
    condition     = can(regex("^[0-9,-]+$", var.health_check_matcher))
    error_message = "VALIDATION: health_check_matcher must contain only digits, commas, and hyphens."
  }
}

variable "health_check_interval" {
  description = "Approximate amount of time, in seconds, between health checks"
  type        = number
  default     = 30

  validation {
    condition     = var.health_check_interval >= 5 && var.health_check_interval <= 300
    error_message = "VALIDATION: health_check_interval must be between 5 and 300 seconds."
  }
}

variable "health_check_timeout" {
  description = "Amount of time, in seconds, during which no response means a failed health check"
  type        = number
  default     = 5

  validation {
    condition     = var.health_check_timeout >= 2 && var.health_check_timeout <= 120
    error_message = "VALIDATION: health_check_timeout must be between 2 and 120 seconds."
  }
}

variable "healthy_threshold" {
  description = "Number of consecutive successful health checks required before considering a target healthy"
  type        = number
  default     = 2

  validation {
    condition     = var.healthy_threshold >= 2 && var.healthy_threshold <= 10
    error_message = "VALIDATION: healthy_threshold must be between 2 and 10."
  }
}

variable "unhealthy_threshold" {
  description = "Number of consecutive failed health checks required before considering a target unhealthy"
  type        = number
  default     = 2

  validation {
    condition     = var.unhealthy_threshold >= 2 && var.unhealthy_threshold <= 10
    error_message = "VALIDATION: unhealthy_threshold must be between 2 and 10."
  }
}

variable "vpc_cidr_block" {
  description = "The CIDR block of the VPC for internal network access"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr_block))
    error_message = "VALIDATION: All vpc_cidr_block must be valid CIDRs."
  }
}

variable "environment" {
  description = "Environment tag for resources"
  type        = string
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
}
