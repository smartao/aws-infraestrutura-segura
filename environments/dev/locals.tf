locals {
  common_tags = {
    ManagedBy   = "Terraform"
    Owner       = var.owner
    Project     = var.project
    Environment = var.environment
  }
  name_prefix = "${var.project}-${var.environment}"

  ssh_public_key_path = "${path.module}/keys/${var.ssh_key_name}"
  bastion_user_data   = "${path.module}/scripts/${var.bastion_script}"
  app_user_data = templatefile("${path.module}/scripts/${var.app_script}", {
    html_page_base64 = filebase64("${path.module}/scripts/${var.app_html_page}")
  })

  alb_listener_protocol_upper = upper(var.alb_listener_protocol)
  is_https                    = local.alb_listener_protocol_upper == "HTTPS"
  certificate_arn             = local.is_https ? module.acm[0].certificate_arn : null
  alb_listener_port           = local.is_https ? 443 : 80

}
