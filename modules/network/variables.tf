variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "VALIDATION: vpc_cidr must be a valid CIDR."
  }
}

variable "public_subnet_cidrs" {
  description = "A list of CIDR blocks for the public subnets"
  type        = list(string)

  validation {
    condition     = alltrue([for cidr in var.public_subnet_cidrs : can(cidrnetmask(cidr))])
    error_message = "VALIDATION: All public_subnet_cidrs must be valid CIDRs."
  }

  validation {
    condition     = length(var.public_subnet_cidrs) >= 2
    error_message = "VALIDATION: At least two public subnet CIDRs must be specified."
  }
}

variable "private_subnet_cidrs" {
  description = "A list of CIDR blocks for the private subnets"
  type        = list(string)

  validation {
    condition     = alltrue([for cidr in var.private_subnet_cidrs : can(cidrnetmask(cidr))])
    error_message = "VALIDATION: All private_subnet_cidrs must be valid CIDRs."
  }

  validation {
    condition     = length(var.private_subnet_cidrs) >= 2
    error_message = "VALIDATION: At least two private subnet CIDRs must be specified."
  }
}

variable "azs" {
  description = "A list of availability zones to use"
  type        = list(string)
  validation {
    condition     = length(var.azs) >= 2
    error_message = "VALIDATION: At least two Availability Zones must be specified for high availability."
  }

  validation {
    condition     = length(distinct(var.azs)) == length(var.azs)
    error_message = "VALIDATION: azs must not contain duplicate Availability Zones."
  }
}

variable "environment" {
  description = "Environment tag for resources"
  type        = string

  validation {
    condition     = length(trimspace(var.environment)) > 0
    error_message = "VALIDATION: environment must not be empty."
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
