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
# Module: Bastion
# =============================================================================
module "bastion" {
  source = "../../modules/bastion"

  vpc_id                    = module.network.vpc_id
  public_subnet_ids         = module.network.public_subnet_ids
  name_prefix               = local.name_prefix
  ssh_public_key            = file("${path.root}/keys/${var.ssh_public_key}")
  instance_type             = var.instance_type
  bastion_ssh_ingress_cidrs = var.bastion_ssh_ingress_cidrs
  environment               = var.environment
}

# =============================================================================
# Module: ALB
# =============================================================================
module "alb" {
  source = "../../modules/alb"

  vpc_id             = module.network.vpc_id
  vpc_cidr_block     = module.network.vpc_cidr_block
  private_subnet_ids = module.network.private_subnet_ids
  name_prefix        = local.name_prefix
  app_port           = var.app_port
  app_protocol       = var.app_protocol
  azs                = var.azs
  environment        = var.environment
  common_tags        = local.common_tags
}


# =============================================================================
# Module: APP
# =============================================================================

module "app" {
  source = "../../modules/app"

  vpc_id               = module.network.vpc_id
  private_subnet_ids   = module.network.private_subnet_ids
  sg_alb_id            = module.alb.sg_alb_id
  app_target_group_arn = module.alb.app_target_group_arn
  bastion_sg_id        = module.bastion.bastion_sg_id
  ssh_public_key       = file("${path.root}/keys/${var.ssh_public_key}")
  instance_type        = var.instance_type
  app_port             = var.app_port
  app_protocol         = var.app_protocol
  app_user_data        = var.user_data
  asg_min_size         = var.asg_min_size
  asg_max_size         = var.asg_max_size
  asg_desired_capacity = var.asg_desired_capacity
  name_prefix          = local.name_prefix
  common_tags          = local.common_tags
}
