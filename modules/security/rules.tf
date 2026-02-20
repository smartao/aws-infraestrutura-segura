
# Rules for bastion host
resource "aws_security_group_rule" "allow_bastion_to_internet" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_bastion.id
  description       = "Allow all outbound traffic from Bastion Host"
}

resource "aws_security_group_rule" "allow_ssh_bastion_from_internet" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.bastion_ssh_ingress_cidrs
  security_group_id = aws_security_group.sg_bastion.id
  description       = "Allow SSH from trusted IPs"
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
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr_block]
  security_group_id = aws_security_group.sg_alb.id
  description       = "Allow HTTP from internal network"
}

resource "aws_security_group_rule" "allow_https_from_vpc_to_alb" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr_block]
  security_group_id = aws_security_group.sg_alb.id
  description       = "Allow HTTPS from internal network"
}


# Rules for APP
resource "aws_security_group_rule" "allow_app_to_internet" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_app.id
  description       = "Allow all outbound traffic from APP"
}


resource "aws_security_group_rule" "allow_http_app_from_alb" {
  type                     = "ingress"
  from_port                = 80 # Assuming application serves on port 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sg_alb.id
  security_group_id        = aws_security_group.sg_app.id
  description              = "Allows HTTP traffic from SG-ALB"
}

resource "aws_security_group_rule" "allow_https_app_from_alb" {
  type                     = "ingress"
  from_port                = 443 # Assuming application serves on port 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sg_alb.id
  security_group_id        = aws_security_group.sg_app.id
  description              = "Allows HTTPS traffic from SG-ALB"
}

# SG-APP allows SSH from SG-BASTION
resource "aws_security_group_rule" "allow_ssh_app_from_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sg_bastion.id
  security_group_id        = aws_security_group.sg_app.id
  description              = "Allows SSH traffic from SG-BASTION"
}
# Reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule