# =============================================================================
# Global Configuration
# =============================================================================
variable "region" {
  description = "AWS region"
  type        = string
}

# =============================================================================
# Tagging Configuration
# =============================================================================
variable "environment" {
  description = "Environment (e.g., dev, stg, prod)"
  type        = string
}

variable "owner" {
  description = "Resource owner"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
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

variable "azs" {
  description = "A list of availability zones to use"
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

