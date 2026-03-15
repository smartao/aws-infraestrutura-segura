
# SG - Security Group for Application Load Balancer (ALB)
resource "aws_security_group" "sg_alb" {
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
  type              = "egress"
  from_port         = var.target_group_port
  to_port           = var.target_group_port
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr_block]
  security_group_id = aws_security_group.sg_alb.id
  description       = "Allow ALB outbound traffic only to application targets inside the VPC"
}

resource "aws_security_group_rule" "allow_http_from_vpc_to_alb" {
  type              = "ingress"
  from_port         = var.listener_port
  to_port           = var.listener_port
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr_block]
  security_group_id = aws_security_group.sg_alb.id
  description       = "Allow HTTP from internal network"
}


# Application Load Balancer
resource "aws_lb" "internal_alb" {
  name                       = "${var.name_prefix}-internal-alb"
  internal                   = true
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.sg_alb.id]
  subnets                    = var.private_subnet_ids
  idle_timeout               = var.alb_idle_timeout
  enable_deletion_protection = var.enable_deletion_protection
  drop_invalid_header_fields = var.drop_invalid_header_fields
  enable_http2               = var.enable_http2

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.name_prefix}-internal-alb"
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
  load_balancer_arn = aws_lb.internal_alb.arn
  port              = var.listener_port
  protocol          = var.listener_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_target_group.arn
  }
}
