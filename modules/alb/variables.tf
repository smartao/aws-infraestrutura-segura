variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "create_security_group" {
  description = "Whether the module should create and manage a dedicated security group for the ALB"
  type        = bool
  default     = true
}

variable "security_group_ids" {
  description = "Additional security group IDs to attach to the ALB, or the full list when create_security_group is false"
  type        = list(string)
  default     = []

  validation {
    condition     = var.create_security_group || length(var.security_group_ids) > 0
    error_message = "VALIDATION: security_group_ids must contain at least one security group when create_security_group is false."
  }
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for application instances and internal ALB"
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "VALIDATION: private_subnet_ids must contain at least two private subnets in different Availability Zones."
  }
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

variable "listener_protocol" {
  description = "The protocol used by the ALB listener (e.g., HTTP, HTTPS)"
  type        = string

  validation {
    condition     = contains(["HTTP", "HTTPS"], var.listener_protocol)
    error_message = "VALIDATION: listener_protocol must be either HTTP or HTTPS."
  }
}

variable "target_group_protocol" {
  description = "The protocol used by the ALB target group and health checks (e.g., HTTP, HTTPS)"
  type        = string

  validation {
    condition     = contains(["HTTP", "HTTPS"], var.target_group_protocol)
    error_message = "VALIDATION: target_group_protocol must be either HTTP or HTTPS."
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

variable "alb_idle_timeout" {
  description = "Time in seconds that the connection is allowed to be idle"
  type        = number
  default     = 60

  validation {
    condition     = var.alb_idle_timeout >= 1 && var.alb_idle_timeout <= 4000
    error_message = "VALIDATION: alb_idle_timeout must be between 1 and 4000 seconds."
  }
}

variable "enable_deletion_protection" {
  description = "Defines whether deletion protection is enabled on the ALB"
  type        = bool
  default     = false
}

variable "internal" {
  description = "If true, the LB will be internal. If false, the LB will be public-facing."
  type        = bool
  default     = true
}

variable "drop_invalid_header_fields" {
  description = "Indicates whether HTTP headers with invalid names are removed by the ALB"
  type        = bool
  default     = true
}

variable "enable_http2" {
  description = "Defines whether HTTP/2 is enabled on the ALB"
  type        = bool
  default     = true
}

variable "vpc_cidr_block" {
  description = "The VPC CIDR block used as a fallback when explicit ALB security group CIDR rules are not provided"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr_block))
    error_message = "VALIDATION: All vpc_cidr_block must be valid CIDRs."
  }
}

variable "allowed_ingress_cidr_blocks" {
  description = "CIDR blocks allowed to reach the ALB listener. Defaults to the VPC CIDR when empty."
  type        = list(string)
  default     = []
}

variable "allowed_ingress_security_group_ids" {
  description = "Security group IDs allowed to reach the ALB listener"
  type        = list(string)
  default     = []
}

variable "allowed_egress_cidr_blocks" {
  description = "CIDR blocks the ALB is allowed to reach on the target group port. Defaults to the VPC CIDR when empty."
  type        = list(string)
  default     = []
}

variable "environment" {
  description = "Environment tag for resources"
  type        = string
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate for HTTPS listeners. Required when listener_protocol is HTTPS."
  type        = string
  default     = null
}

variable "ssl_policy" {
  description = "SSL policy for the HTTPS listener"
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}
