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

variable "env_tag" {
  description = "Environment tag for resources"
  type        = string
}
