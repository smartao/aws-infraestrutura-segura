
locals {
  # Defines which CIDR blocks are allowed to access the ALB. 
  # If 'allowed_ingress_cidr_blocks' is empty, it defaults to the entire VPC CIDR.
  alb_ingress_cidr_blocks = length(var.allowed_ingress_cidr_blocks) > 0 ? var.allowed_ingress_cidr_blocks : [var.vpc_cidr_block]

  # Defines which CIDR blocks the ALB can send traffic to (egress).
  # If 'allowed_egress_cidr_blocks' is empty, it defaults to the entire VPC CIDR.
  alb_egress_cidr_blocks = length(var.allowed_egress_cidr_blocks) > 0 ? var.allowed_egress_cidr_blocks : [var.vpc_cidr_block]

  # Consolidates the security group IDs for the ALB.
  # If 'create_security_group' is true, it includes the newly created SG along with any extra SGs provided.
  alb_security_group_ids = var.create_security_group ? concat([aws_security_group.sg_alb[0].id], var.security_group_ids) : var.security_group_ids
}

# SG - Security Group for Application Load Balancer (ALB)
resource "aws_security_group" "sg_alb" {
  count       = var.create_security_group ? 1 : 0
  name        = "${var.name_prefix}-alb-sg"
  description = "Allow HTTP/HTTPS traffic to ALB from internal network"
  vpc_id      = var.vpc_id

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.name_prefix}-alb-sg"
      Environment = var.environment
    }
  )
}

# Rules for ALB
resource "aws_security_group_rule" "allow_alb_to_app_targets" {
  for_each          = var.create_security_group ? toset(local.alb_egress_cidr_blocks) : toset([])
  type              = "egress"
  from_port         = var.target_group_port
  to_port           = var.target_group_port
  protocol          = "tcp"
  cidr_blocks       = [each.value]
  security_group_id = aws_security_group.sg_alb[0].id
  description       = "Allow ALB outbound traffic only to application targets inside the VPC"
}

resource "aws_security_group_rule" "allow_http_from_cidrs_to_alb" {
  for_each          = var.create_security_group ? toset(local.alb_ingress_cidr_blocks) : toset([])
  type              = "ingress"
  from_port         = var.listener_port
  to_port           = var.listener_port
  protocol          = "tcp"
  cidr_blocks       = [each.value]
  security_group_id = aws_security_group.sg_alb[0].id
  description       = "Allow HTTP from internal network"
}

resource "aws_security_group_rule" "allow_http_from_sgs_to_alb" {
  for_each                 = var.create_security_group ? toset(var.allowed_ingress_security_group_ids) : toset([])
  type                     = "ingress"
  from_port                = var.listener_port
  to_port                  = var.listener_port
  protocol                 = "tcp"
  source_security_group_id = each.value
  security_group_id        = aws_security_group.sg_alb[0].id
  description              = "Allow ALB access from trusted security groups"
}

# Application Load Balancer
resource "aws_lb" "alb" {
  name                       = "${var.name_prefix}-alb"
  internal                   = var.internal
  load_balancer_type         = "application"
  security_groups            = local.alb_security_group_ids
  subnets                    = var.private_subnet_ids
  idle_timeout               = var.alb_idle_timeout
  enable_deletion_protection = var.enable_deletion_protection
  drop_invalid_header_fields = var.drop_invalid_header_fields
  enable_http2               = var.enable_http2

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.name_prefix}-alb"
      Environment = var.environment
    }
  )
}

resource "aws_lb_target_group" "app_target_group" {
  name        = "${var.name_prefix}-app-tg"
  port        = var.target_group_port
  protocol    = var.target_group_protocol
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = var.health_check_path
    protocol            = var.target_group_protocol
    matcher             = var.health_check_matcher
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
  }

  lifecycle {
    precondition {
      condition     = var.health_check_timeout < var.health_check_interval
      error_message = "VALIDATION: health_check_timeout must be lower than health_check_interval."
    }
    precondition {
      condition     = length(local.alb_security_group_ids) > 0
      error_message = "VALIDATION: At least one security group must be attached to the ALB."
    }
  }

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.name_prefix}-app-tg"
      Environment = var.environment
    }
  )
}


resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = var.listener_port
  protocol          = var.listener_protocol
  certificate_arn   = var.listener_protocol == "HTTPS" ? var.certificate_arn : null
  ssl_policy        = var.listener_protocol == "HTTPS" ? var.ssl_policy : null

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_target_group.arn
  }

  lifecycle {
    precondition {
      condition     = var.listener_protocol == "HTTPS" ? var.certificate_arn != null : true
      error_message = "VALIDATION: certificate_arn must be provided when listener_protocol is HTTPS."
    }
  }
}
