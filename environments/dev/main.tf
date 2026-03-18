# =============================================================================
# Network Layer
# =============================================================================
module "network" {
  source  = "smartao/secure-vpc/aws"
  version = "1.2.0"

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  azs         = var.azs
  environment = var.environment
  name_prefix = local.name_prefix
}

# =============================================================================
# Access Layer
# =============================================================================
module "bastion" {
  source  = "smartao/bastion/aws"
  version = "3.0.0"

  vpc_id    = module.network.vpc_id
  subnet_id = module.network.public_subnet_ids[0]

  ssh_public_key = file(local.ssh_public_key_path)
  user_data      = file(local.bastion_user_data)

  instance_type             = var.instance_type
  bastion_ssh_ingress_cidrs = var.bastion_ssh_ingress_cidrs

  environment = var.environment
  name_prefix = local.name_prefix
}

# =============================================================================
# Certificate Layer
# =============================================================================
module "acm" {
  source = "../../modules/acm"

  common_name = var.acm_common_name

  environment = var.environment
  name_prefix = local.name_prefix
  common_tags = local.common_tags
}

# =============================================================================
# Edge Layer
# =============================================================================
module "alb" {
  source = "../../modules/alb"

  vpc_id                      = module.network.vpc_id
  vpc_cidr_block              = module.network.vpc_cidr_block
  private_subnet_ids          = module.network.private_subnet_ids
  allowed_ingress_cidr_blocks = [module.network.vpc_cidr_block]
  allowed_egress_cidr_blocks  = module.network.private_subnet_cidr_blocks
  certificate_arn             = module.acm.certificate_arn

  listener_port         = var.alb_listener_port
  listener_protocol     = var.alb_listener_protocol
  target_group_port     = var.app_port
  target_group_protocol = var.app_protocol

  environment = var.environment
  name_prefix = local.name_prefix
  common_tags = local.common_tags
}


# =============================================================================
# Application Layer
# =============================================================================

module "app" {
  source = "../../modules/app"

  vpc_id               = module.network.vpc_id
  private_subnet_ids   = module.network.private_subnet_ids
  sg_alb_id            = module.alb.sg_alb_id
  app_target_group_arn = module.alb.app_target_group_arn
  bastion_sg_id        = module.bastion.bastion_sg_id

  ssh_public_key       = file(local.ssh_public_key_path)
  instance_type        = var.instance_type
  app_port             = var.app_port
  app_protocol         = var.app_protocol
  app_user_data        = local.app_user_data
  asg_min_size         = var.asg_min_size
  asg_max_size         = var.asg_max_size
  asg_desired_capacity = var.asg_desired_capacity

  name_prefix = local.name_prefix
  common_tags = local.common_tags
}
