variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for application instances and internal ALB"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the Bastion Host"
  type        = list(string)
}

variable "sg_alb_id" {
  description = "The ID of the Security Group for the Application Load Balancer"
  type        = string
}

variable "sg_app_id" {
  description = "The ID of the Security Group for the Application EC2 instances"
  type        = string
}

variable "sg_bastion_id" {
  description = "The ID of the Security Group for the Bastion Host"
  type        = string
}

variable "instance_type" {
  description = "The instance type for the EC2 instances"
  type        = string

  validation {
    condition     = can(regex("^t3\\.", var.instance_type))
    error_message = "VALIDATION: Instance type must belong to the t3 family."
  }
}

variable "app_user_data" {
  description = "User data script for application EC2 instances"
  type        = string

  validation {
    condition     = fileexists("${path.module}/scripts/${var.app_user_data}")
    error_message = "VALIDATION: The specified user_data file does not exist in the Terraform root directory."
  }
}

variable "azs" {
  description = "A list of availability zones to use"
  type        = list(string)
}

variable "public_key" {
  description = "The public key for SSH access to EC2 instances"
  type        = string

  validation {
    condition     = can(regex("^ssh-(rsa|ed25519)\\s+[A-Za-z0-9+/=]+", var.public_key))
    error_message = "VALIDATION: Invalid SSH public key format."
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

variable "environment" {
  description = "Environment tag for resources"
  type        = string

  validation {
    condition     = contains(["tst", "dev", "stage", "prod"], var.environment)
    error_message = "VALIDATION: Invalid environment. Allowed values: tst, dev, stage ou prod."
  }
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
}