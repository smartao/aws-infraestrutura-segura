output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.network.private_subnet_ids
}

output "sg_bastion_id" {
  description = "The ID of the Security Group for the Bastion Host"
  value       = module.security.sg_bastion_id
}

output "sg_alb_id" {
  description = "The ID of the Security Group for the Application Load Balancer"
  value       = module.security.sg_alb_id
}

output "sg_app_id" {
  description = "The ID of the Security Group for the Application EC2 instances"
  value       = module.security.sg_app_id
}


output "alb_dns_name" {
  description = "The DNS name of the internal Application Load Balancer"
  value       = module.compute.alb_dns_name
}

output "bastion_public_ip" {
  description = "The public IP address of the Bastion Host. Use this to SSH into the bastion."
  value       = module.compute.bastion_public_ip
}
