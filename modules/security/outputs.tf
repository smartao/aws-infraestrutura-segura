output "sg_bastion_id" {
  description = "The ID of the Security Group for the Bastion Host"
  value       = aws_security_group.sg_bastion.id
}

output "sg_alb_id" {
  description = "The ID of the Security Group for the Application Load Balancer"
  value       = aws_security_group.sg_alb.id
}

output "sg_app_id" {
  description = "The ID of the Security Group for the Application EC2 instances"
  value       = aws_security_group.sg_app.id
}
