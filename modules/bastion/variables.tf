variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the Bastion Host"
  type        = list(string)
}

variable "environment" {
  description = "Environment tag for resources"
  type        = string
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

variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string

  validation {
    condition     = length(var.name_prefix) <= 32
    error_message = "VALIDATION: name_prefix must be <= 32 characters."
  }
}

variable "instance_type" {
  description = "The instance type for the EC2 instances"
  type        = string
  default     = "t3.micro"
  validation {
    condition     = can(regex("^t3\\.", var.instance_type))
    error_message = "VALIDATION: Instance type must belong to the t3 family."
  }
}


variable "ssh_public_key" {
  description = "The public key for SSH access to EC2 instances"
  type        = string

  validation {
    condition     = can(regex("^ssh-(rsa|ed25519)\\s+[A-Za-z0-9+/=]+", var.ssh_public_key))
    error_message = "VALIDATION: Invalid SSH public key format."
  }
}