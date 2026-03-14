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
