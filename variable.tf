# =============================================================================
# Global Configuration
# =============================================================================
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# =============================================================================
# Tagging Configuration
# =============================================================================
variable "environment" {
  description = "Environment (e.g., dev, stg, prod)"
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Resource owner"
  type        = string
  default     = "Sergei"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "infra-segura"
}

# =============================================================================
# Network Configuration
# =============================================================================
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "A list of CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "A list of CIDR blocks for the private subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "azs" {
  description = "A list of availability zones to use"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# =============================================================================
# Compute Configuration
# =============================================================================

variable "public_key" {
  description = "The public key for SSH access to EC2 instances"
  type        = string
  default     = "/home/sergei/.ssh/id_rsa.pub"

}
variable "bastion_ssh_ingress_cidrs" {
  description = "List of CIDR blocks allowed to SSH into the bastion host"
  type        = list(string)
  default     = ["0.0.0.0/0"] # WARNING: In a real scenario, restrict this to trusted IPs
}


variable "ami_id" {
  description = "The AMI ID for the EC2 instances"
  type        = string
  default     = "ami-053b0d53c279acc90" # Example AMI for Amazon Linux 2 (us-east-1)
}

variable "instance_type" {
  description = "The instance type for the EC2 instances"
  type        = string
  default     = "t3.micro"
}

variable "app_port" {
  description = "The port on which the application listens"
  type        = number
  default     = 80
}

variable "app_protocol" {
  description = "The protocol used by the application (e.g., HTTP, HTTPS)"
  type        = string
  default     = "HTTP"
}

variable "app_user_data" {
  description = "User data script for application EC2 instances"
  type        = string
  default     = <<-EOF
              #!/bin/bash
              sudo apt update;
              sudo apt install -y nginx;
              sudo systemctl start nginx;
              sudo systemctl enable nginx;
              echo "Pagina $HOSTNAME" | sudo tee /var/www/html/index.nginx-debian.html;
              EOF
}
