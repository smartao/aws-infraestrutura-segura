output "alb_dns_name" {
  description = "The DNS name of the internal Application Load Balancer"
  value       = aws_lb.internal_alb.dns_name
}

output "alb_arn" {
  description = "The ARN of the internal Application Load Balancer"
  value       = aws_lb.internal_alb.arn
}

