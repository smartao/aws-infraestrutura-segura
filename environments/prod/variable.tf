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

    error_message = "VALIDATION: Invalid AWS region. Allowed regions are: us-east-1, us-east-2, us-west-1, us-west-2."
  }
}

variable "azs" {
  description = "A list of availability zones to use"
  type        = list(string)

  validation {
    condition     = length(var.azs) >= 2
    error_message = "VALIDATION: At least two Availability Zones must be specified for high availability."
  }
}

# =============================================================================
## Tagging Configuration
# =============================================================================
variable "environment" {
  description = "Environment (e.g., dev, stg, prod)"
  type        = string
  default     = "stage"
}

variable "owner" {
  description = "Resource owner"
  type        = string
  validation {
    condition     = length(var.owner) > 2
    error_message = "VALIDATION: Owner must contain at least 3 characters."
  }
}

variable "project" {
  description = "Project name"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project))
    error_message = "VALIDATION: Project name must contain only lowercase letters, numbers, and hyphens."
  }
}


# =============================================================================
# Network Configuration
# =============================================================================
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "A list of CIDR blocks for the public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "A list of CIDR blocks for the private subnets"
  type        = list(string)
}

# =============================================================================
# Compute Configuration
# =============================================================================
variable "public_key" {
  description = "The public key for SSH access to EC2 instances"
  type        = string

}
variable "bastion_ssh_ingress_cidrs" {
  description = "List of CIDR blocks allowed to SSH into the bastion host"
  type        = list(string)
}

variable "instance_type" {
  description = "The instance type for the EC2 instances"
  type        = string
}

variable "app_port" {
  description = "The port on which the application listens"
  type        = number
}

variable "app_protocol" {
  description = "The protocol used by the application (e.g., HTTP, HTTPS)"
  type        = string
}

variable "user_data" {
  description = "The user data script to initialize the EC2 instances"
  type        = string
}