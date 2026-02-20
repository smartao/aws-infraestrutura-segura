# -----------------------------------------------------------------------------
# Module: Network
# -----------------------------------------------------------------------------
module "network" {
  source = "./modules/network"

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = var.azs
}

# -----------------------------------------------------------------------------
# Module: Security
# -----------------------------------------------------------------------------
module "security" {
  source = "./modules/security"

  vpc_id                    = module.network.vpc_id
  vpc_cidr_block            = module.network.vpc_cidr_block
  bastion_ssh_ingress_cidrs = var.bastion_ssh_ingress_cidrs
}