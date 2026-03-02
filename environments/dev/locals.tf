locals {
  common_tags = {
    ManagedBy   = "Terraform"
    Owner       = var.owner
    Project     = var.project
    Environment = var.environment
  }
  name_prefix = "${var.project}-${var.environment}"
}