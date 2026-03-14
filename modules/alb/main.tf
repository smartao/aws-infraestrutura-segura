
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
resource "aws_security_group_rule" "allow_alb_to_internet" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_alb.id
  description       = "Allow all outbound traffic from ALB"
}

resource "aws_security_group_rule" "allow_http_from_vpc_to_alb" {
  type              = "ingress"
  from_port         = var.app_port
  to_port           = var.app_port
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr_block]
  security_group_id = aws_security_group.sg_alb.id
  description       = "Allow HTTP from internal network"
}


# Application Load Balancer
resource "aws_lb" "internal_alb" {
  name               = "${var.name_prefix}-internal-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_alb.id]
  subnets            = var.private_subnet_ids

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
  port        = var.app_port
  protocol    = var.app_protocol
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"
    protocol            = var.app_protocol
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.name_prefix}-app-tg"
      Environment = var.environment
    }
  )
}


resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.internal_alb.arn
  port              = var.app_port
  protocol          = var.app_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_target_group.arn
  }
}
