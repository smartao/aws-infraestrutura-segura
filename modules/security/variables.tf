variable "vpc_id" {
  description = "The ID of the VPC to associate security groups with"
  type        = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block of the VPC for internal network access"
  type        = string

  validation { # FIX CORRIGIR
    condition     = can(cidrnetmask(var.vpc_cidr_block))
    error_message = "VALIDATION: All vpc_cidr_block must be valid CIDRs."
  }
}

variable "bastion_ssh_ingress_cidrs" {
  description = "List of CIDR blocks allowed to SSH into the bastion host"
  type        = list(string)

  validation {
    condition = (
      var.environment != "prod" ||
      !contains(var.bastion_ssh_ingress_cidrs, "0.0.0.0/0")
    )
    error_message = "VALIDATION: In production, SSH access cannot be open to 0.0.0.0/0."
  }
}

variable "environment" {
  description = "Environment tag for resources"
  type        = string

  validation {
    condition     = contains(["tst", "dev", "stage", "prod"], var.environment)
    error_message = "VALIDATION: Invalid environment. Allowed values: tst, dev, stage ou prod."
  }
}

variable "app_port" {
  description = "The port on which the application listens"
  type        = number
  validation {
    condition     = var.app_port > 0 && var.app_port < 65536
    error_message = "VALIDATION: Application port must be between 1 and 65535."
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

variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string

  validation {
    condition     = length(var.name_prefix) <= 32
    error_message = "VALIDATION: name_prefix must be <= 32 characters."
  }
}