locals {
  common_tags = {
    ManagedBy   = "Terraform"
    Owner       = var.owner
    Project     = var.project
    Environment = var.environment
  }
  name_prefix         = "${var.project}-${var.environment}"
  ssh_public_key_path = "${path.root}/keys/${var.ssh_key_name}"
  user_data_file_path = "${path.root}/scripts/${var.user_data}"

}