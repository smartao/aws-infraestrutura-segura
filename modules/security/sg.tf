# SG - Security Group for Bastion Host
resource "aws_security_group" "sg_bastion" {
  name        = "bastion-sg"
  description = "Allow SSH access to Bastion Host"
  vpc_id      = var.vpc_id

  tags = {
    Name = "bastion-sg"
  }
}

# SG - Security Group for Application Load Balancer (ALB)
resource "aws_security_group" "sg_alb" {
  name        = "alb-sg"
  description = "Allow HTTP/HTTPS traffic to ALB from internal network"
  vpc_id      = var.vpc_id

  tags = {
    Name = "alb-sg"
  }
}

# SG - Security Group for Application Instances
resource "aws_security_group" "sg_app" {
  name        = "app-sg"
  description = "Allow traffic to application instances from ALB and SSH from Bastion"
  vpc_id      = var.vpc_id

  tags = {
    Name = "app-sg"
  }
}
# Reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
