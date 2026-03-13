locals {
  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Module      = "network"
  }


  public_subnets = {
    for idx, cidr in var.public_subnet_cidrs : var.azs[idx] => {
      az   = var.azs[idx]
      cidr = cidr
    }
  }

  private_subnets = {
    for idx, cidr in var.private_subnet_cidrs : var.azs[idx] => {
      az   = var.azs[idx]
      cidr = cidr
    }
  }
}
