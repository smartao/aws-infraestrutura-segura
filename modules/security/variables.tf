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
}