# =============================================================================
# Network Layer
# =============================================================================
module "network" {
  source  = "smartao/secure-vpc/aws"
  version = "1.1.0"

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
  version = "1.0.0"

  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids

  ssh_public_key = file(local.ssh_public_key_path)
  user_data      = file(local.bastion_user_data)

  instance_type             = var.instance_type
  bastion_ssh_ingress_cidrs = var.bastion_ssh_ingress_cidrs



  environment = var.environment
  name_prefix = local.name_prefix
}

# =============================================================================
# Edge Layer
# =============================================================================
module "alb" {
  source = "../../modules/alb"

  vpc_id             = module.network.vpc_id
  vpc_cidr_block     = module.network.vpc_cidr_block
  private_subnet_ids = module.network.private_subnet_ids

  allowed_ingress_cidr_blocks = var.alb_allowed_ingress_cidr_blocks
  allowed_egress_cidr_blocks  = var.alb_allowed_egress_cidr_blocks
  listener_port               = var.alb_listener_port
  target_group_port           = var.app_port
  listener_protocol           = var.alb_listener_protocol
  target_group_protocol       = var.app_protocol
  health_check_path           = var.health_check_path
  health_check_matcher        = var.health_check_matcher
  health_check_interval       = var.health_check_interval
  health_check_timeout        = var.health_check_timeout
  healthy_threshold           = var.healthy_threshold
  unhealthy_threshold         = var.unhealthy_threshold

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
