output "alb_dns_name" {
  description = "The DNS name of the internal Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "bastion_public_ip" {
  description = "The public IP address of the Bastion Host. Use this to SSH into the bastion."
  value       = module.bastion.bastion_public_ip
}

output "access_information" {
  description = "Useful commands and URLs"
  sensitive   = false

  value = var.dev_access_information ? (
    <<EOT

========== Infrastructure Access Information ==========

🔐 Bastion SSH:
ssh -o StrictHostKeyChecking=accept-new ubuntu@${module.bastion.bastion_public_ip}

🌍 Application URL:
${lower(var.alb_listener_protocol)}://${module.alb.alb_dns_name}

🧪 Load balance test via bastion host
while true; do curl -sk ${lower(var.alb_listener_protocol)}://${module.alb.alb_dns_name} ; sleep 1; done

=======================================================

EOT
  ) : null
}
