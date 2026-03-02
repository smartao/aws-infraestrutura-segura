# =============================================================================
# Module: Network
# =============================================================================
module "network" {
  source = "../../modules/network"

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = var.azs
  environment          = var.environment
  name_prefix          = local.name_prefix
}

# =============================================================================
# Module: Security
# =============================================================================
module "security" {
  source = "../../modules/security"

  vpc_id                    = module.network.vpc_id
  vpc_cidr_block            = module.network.vpc_cidr_block
  bastion_ssh_ingress_cidrs = var.bastion_ssh_ingress_cidrs
  environment               = var.environment
  app_port                  = var.app_port
  app_protocol              = var.app_protocol
  name_prefix               = local.name_prefix
}


# =============================================================================
# Module: Compute
# =============================================================================
module "compute" {
  source = "../../modules/compute"

  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids
  public_subnet_ids  = module.network.public_subnet_ids
  sg_alb_id          = module.security.sg_alb_id
  sg_app_id          = module.security.sg_app_id
  sg_bastion_id      = module.security.sg_bastion_id
  name_prefix        = local.name_prefix
  public_key         = file("${path.root}/keys/${var.public_key}")
  instance_type      = var.instance_type
  app_user_data      = var.user_data
  app_port           = var.app_port
  app_protocol       = var.app_protocol
  azs                = var.azs
  environment        = var.environment
  common_tags        = local.common_tags
}
