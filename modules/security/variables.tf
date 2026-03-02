variable "vpc_id" {
  description = "The ID of the VPC to associate security groups with"
  type        = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block of the VPC for internal network access"
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

variable "environment" {
  description = "Environment tag for resources"
  type        = string

  validation {
    condition     = contains(["tst", "dev", "stage", "prod"], var.environment)
    error_message = "VALIDATION: Invalid environment. Allowed values: tst, dev, stage ou prod."
  }
}