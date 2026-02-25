# =============================================================================
# Compute Configuration
# =============================================================================
variable "public_key" {
  description = "The public key for SSH access to EC2 instances"
  type        = string

  validation {
    condition     = can(regex("\\.pub$", var.public_key))
    error_message = "The public_key must reference a .pub file."
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

    error_message = "In production, SSH access cannot be open to 0.0.0.0/0."
  }
}

variable "instance_type" {
  description = "The instance type for the EC2 instances"
  type        = string

  validation {
    condition     = can(regex("^t3\\.", var.instance_type))
    error_message = "Instance type must belong to the t3 family."
  }
}

variable "app_port" {
  description = "The port on which the application listens"
  type        = number

  validation {
    condition     = var.app_port > 0 && var.app_port < 65536
    error_message = "Application port must be between 1 and 65535."
  }
}

variable "app_protocol" {
  description = "The protocol used by the application (e.g., HTTP, HTTPS)"
  type        = string

  validation {
    condition     = contains(["HTTP", "HTTPS"], var.app_protocol)
    error_message = "Application protocol must be either HTTP or HTTPS."
  }
}

variable "user_data" {
  description = "The user data script to initialize the EC2 instances"
  type        = string

  validation {
    condition     = fileexists("${path.module}/scripts/${var.user_data}")
    error_message = "The specified user_data file does not exist in the Terraform root directory."
  }
}