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

variable "ami_id" {
  description = "The AMI ID for the EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "The instance type for the EC2 instances"
  type        = string
}

variable "app_user_data" {
  description = "User data script for application EC2 instances"
  type        = string
}

variable "azs" {
  description = "A list of availability zones to use"
  type        = list(string)
}

variable "public_key" {
  description = "The public key for SSH access to EC2 instances"
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

variable "environment" {
  description = "Environment tag for resources"
  type        = string
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
}