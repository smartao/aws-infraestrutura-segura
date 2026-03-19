output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = aws_lb.alb.dns_name
}

output "alb_arn" {
  description = "The ARN of the Application Load Balancer"
  value       = aws_lb.alb.arn
}

output "app_target_group_arn" {
  description = "The ARN of the ALB Target Group for the application"
  value       = aws_lb_target_group.app_target_group.arn
}

output "sg_alb_id" {
  description = "The ID of the Security Group for the Application Load Balancer"
  value       = var.create_security_group ? aws_security_group.sg_alb[0].id : var.security_group_ids[0]
}
