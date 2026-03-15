# =============================================================================
# Module: Global
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


# Tagging Conventions

variable "environment" {
  description = "Environment (e.g., dev, stg, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["tst", "dev", "stage", "prod"], var.environment)
    error_message = "VALIDATION: Invalid environment. Allowed values: tst, dev, stage ou prod."
  }
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
# Module: Network
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
# Module: Bastion
# =============================================================================
variable "bastion_ssh_ingress_cidrs" {
  description = "List of CIDR blocks allowed to SSH into the bastion host"
  type        = list(string)
}

variable "ssh_key_name" {
  description = "Filename of the SSH public key stored in the keys directory"
  type        = string
}

variable "bastion_script" {
  description = "The user data script to initialize the bastion host"
  type        = string
  default     = "bastion.sh"
}

# =============================================================================
# Module: ALB
# =============================================================================
variable "alb_listener_port" {
  description = "The port on which the internal ALB listens"
  type        = number
}

variable "alb_listener_protocol" {
  description = "The protocol used by the internal ALB listener"
  type        = string
  default     = "HTTP"
}

variable "alb_allowed_ingress_cidr_blocks" {
  description = "Trusted CIDR blocks allowed to access the internal ALB listener"
  type        = list(string)
  default     = []
}

variable "alb_allowed_egress_cidr_blocks" {
  description = "CIDR blocks the internal ALB can reach on the target group port"
  type        = list(string)
  default     = []
}

variable "health_check_path" {
  description = "The destination for the ALB target group health check request"
  type        = string
  default     = "/"
}

variable "health_check_matcher" {
  description = "The HTTP codes to use when checking for a successful health check response"
  type        = string
  default     = "200"
}

variable "health_check_interval" {
  description = "Approximate amount of time, in seconds, between health checks"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Amount of time, in seconds, during which no response means a failed health check"
  type        = number
  default     = 5
}

variable "healthy_threshold" {
  description = "Number of consecutive successful health checks required before considering a target healthy"
  type        = number
  default     = 2
}

variable "unhealthy_threshold" {
  description = "Number of consecutive failed health checks required before considering a target unhealthy"
  type        = number
  default     = 2
}

# =============================================================================
# Module: App
# =============================================================================
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

variable "app_script" {
  description = "The application script to initialize the EC2 instances"
  type        = string
}

variable "app_html_page" {
  description = "The HTML template deployed by the application user data"
  type        = string
  default     = "index.html.tpl"
}

# =============================================================================
# Module: Auto Scaling
# =============================================================================
variable "asg_desired_capacity" {
  description = "Desired number of instances in the ASG"
  type        = number
}

variable "asg_min_size" {
  description = "Minimum number of instances in the ASG"
  type        = number
}

variable "asg_max_size" {
  description = "Maximum number of instances in the ASG"
  type        = number
}
