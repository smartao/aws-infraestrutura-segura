output "app_security_group_id" {
  description = "The ID of the application security group"
  value       = aws_security_group.sg_app.id
}
output "asg_arn" {
  description = "The ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.app_asg.arn
}

output "launch_template_id" {
  description = "The ID of the Launch Template"
  value       = aws_launch_template.app_launch_template.id
}
