output "web_acl_id" {
  description = "The ID of the WAFv2 Web ACL"
  value       = aws_wafv2_web_acl.main.id
}

output "web_acl_arn" {
  description = "The ARN of the WAFv2 Web ACL"
  value       = aws_wafv2_web_acl.main.arn
}

output "web_acl_capacity" {
  description = "The Web ACL capacity units (WCUs) currently being used by this web ACL"
  value       = aws_wafv2_web_acl.main.capacity
}
