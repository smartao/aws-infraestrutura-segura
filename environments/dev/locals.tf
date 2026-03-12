locals {
  common_tags = {
    ManagedBy   = "Terraform"
    Owner       = var.owner
    Project     = var.project
    Environment = var.environment
  }
  name_prefix         = "${var.project}-${var.environment}"
  ssh_public_key_path = "${path.module}/keys/${var.ssh_key_name}"
  user_data_file_path = "${path.module}/scripts/${var.app_script}"
  bastion_user_data   = "${path.module}/scripts/${var.bastion_script}"

}