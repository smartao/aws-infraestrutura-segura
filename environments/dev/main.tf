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
  source  = "smartao/acm-self-signed/aws"
  version = "1.1.0"

  count = var.alb_listener_protocol == "HTTPS" ? 1 : 0

  common_name = var.acm_common_name

  environment = var.environment
  name_prefix = local.name_prefix
  common_tags = local.common_tags
}

# =============================================================================
# Edge Layer
# =============================================================================
module "alb" {
  source  = "smartao/alb/aws"
  version = "2.1.1"

  vpc_id         = module.network.vpc_id
  vpc_cidr_block = module.network.vpc_cidr_block
  subnet_ids     = module.network.private_subnet_ids

  certificate_arn = local.certificate_arn

  listener_port         = var.alb_listener_port
  listener_protocol     = var.alb_listener_protocol
  target_group_port     = var.app_port
  target_group_protocol = var.app_protocol

  environment = var.environment
  name_prefix = local.name_prefix
  common_tags = local.common_tags
}

module "waf" {
  source = "../../modules/waf"

  count = var.enable_waf ? 1 : 0

  alb_arn = module.alb.alb_arn

  name_prefix = local.name_prefix
  common_tags = local.common_tags
}

# =============================================================================
# Validation Layer
# =============================================================================
resource "terraform_data" "validate_waf" {
  lifecycle {
    precondition {
      condition     = var.environment == "prod" ? var.enable_waf : true
      error_message = "VALIDATION ERROR: WAF must be enabled (enable_waf = true) when environment is 'prod'."
    }
  }
}

resource "terraform_data" "validate_alb_protocol" {
  lifecycle {
    precondition {
      condition     = var.environment == "prod" ? var.alb_listener_protocol == "HTTPS" : true
      error_message = "VALIDATION ERROR: ALB listener protocol must be 'HTTPS' when environment is 'prod'."
    }
  }
}

# =============================================================================
# Application Layer
# =============================================================================

module "app" {
  source  = "smartao/ec2-autoscaling-app/aws"
  version = "1.0.0"

  vpc_id               = module.network.vpc_id
  private_subnet_ids   = module.network.private_subnet_ids
  sg_alb_id            = module.alb.sg_alb_id
  app_target_group_arn = module.alb.app_target_group_arn

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
