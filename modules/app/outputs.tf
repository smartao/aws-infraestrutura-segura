output "app_security_group_id" {
  description = "ID do Security Group da aplicação"
  value       = aws_security_group.sg_app.id
}
output "asg_arn" {
  description = "ARN do Auto Scaling Group"
  value       = aws_autoscaling_group.app_asg.arn
}

output "launch_template_id" {
  description = "ID do Launch Template"
  value       = aws_launch_template.app_launch_template.id
}
