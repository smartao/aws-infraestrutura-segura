variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for application instances and internal ALB"
  type        = list(string)
}

variable "sg_alb_id" {
  description = "The ID of the Security Group for the Application Load Balancer"
  type        = string
}


variable "app_target_group_arn" {
  description = "The ARN of the ALB Target Group for the application"
  type        = string
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

variable "ssm_parameter_name" {
  description = "The name of the SSM parameter that contains the AMI ID Launch Template"
  type        = string
  default     = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

variable "instance_type" {
  description = "The instance type for the EC2 instances"
  type        = string
  default     = "t3.micro"
}


variable "disk_volume_size" {
  description = "The size of the EBS volume in GB"
  type        = number
  default     = 20

  validation {
    condition     = var.disk_volume_size >= 20 && var.disk_volume_size <= 16384
    error_message = "VALIDATION: disk_volume_size must be between 20 and 16384 GB."
  }
}

variable "disk_volume_type" {
  description = "The type of the EBS volume"
  type        = string
  default     = "gp3"

  validation {
    condition = contains(
      ["gp3", "gp2", "io1", "io2", "st1", "sc1"],
      var.disk_volume_type
    )
    error_message = "VALIDATION: disk_volume_type must be: gp3, gp2, io1, io2, st1 or sc1."
  }
}

variable "disk_encrypted" {
  description = "Defines whether the EBS volume will be encrypted."
  type        = bool
  default     = true
}

variable "disk_delete_on_termination" {
  description = "Defines whether the EBS volume will be deleted when the instance is terminated."
  type        = bool
  default     = true
}

variable "app_user_data" {
  description = "Rendered user data script for application EC2 instances"
  type        = string
}

variable "asg_desired_capacity" {
  description = "Desired number of instances in the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "asg_min_size" {
  description = "Minimum number of instances in the ASG"
  type        = number
  default     = 2

  validation {
    condition     = var.asg_min_size >= 1
    error_message = "VALIDATION: asg_min_size must be at least 1."
  }
}

variable "asg_max_size" {
  description = "Maximum number of instances in the ASG"
  type        = number
  default     = 3
}

variable "asg_health_check_grace_period" {
  description = "Time (in seconds) that Auto Scaling waits before checking the health status of an instance after it enters the InService state"
  type        = number
  default     = 300
  validation {
    condition     = var.asg_health_check_grace_period >= 0 && var.asg_health_check_grace_period <= 3600
    error_message = "VALIDATION: asg_health_check_grace_period must be between 0 and 3600 seconds."
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

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
}
