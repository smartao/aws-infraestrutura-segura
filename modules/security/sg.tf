# SG - Security Group for Bastion Host
resource "aws_security_group" "sg_bastion" {
  name        = "${var.name_prefix}-bastion-sg"
  description = "Allow SSH access to Bastion Host"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-bastion-sg"
  }
}

# SG - Security Group for Application Load Balancer (ALB)
resource "aws_security_group" "sg_alb" {
  name        = "${var.name_prefix}-alb-sg"
  description = "Allow HTTP/HTTPS traffic to ALB from internal network"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-alb-sg"
  }
}

# SG - Security Group for Application Instances
resource "aws_security_group" "sg_app" {
  name        = "${var.name_prefix}-app-sg"
  description = "Allow traffic to application instances from ALB and SSH from Bastion"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-app-sg"
  }
}