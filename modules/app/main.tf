locals {
  rendered_user_data = filebase64("${var.app_user_data}")
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

# Rules for APP
#tfsec:ignore:aws-ec2-no-public-egress-sgr
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
  from_port                = var.app_port
  to_port                  = var.app_port
  protocol                 = "tcp"
  source_security_group_id = var.sg_alb_id
  security_group_id        = aws_security_group.sg_app.id
  description              = "Allows HTTP traffic from SG-ALB"
}


# SG-APP allows SSH from SG-BASTION
resource "aws_security_group_rule" "allow_ssh_app_from_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = var.bastion_sg_id
  security_group_id        = aws_security_group.sg_app.id
  description              = "Allows SSH traffic from SG-BASTION"
}

data "aws_ssm_parameter" "ubuntu" {
  name = var.ssm_parameter_name
}

resource "aws_key_pair" "generated_key" {
  key_name   = "${var.name_prefix}-app-key"
  public_key = var.ssh_public_key
}


# Application EC2 Instances (via Launch Template and Auto Scaling Group)
resource "aws_launch_template" "app_launch_template" {
  name_prefix            = "${var.name_prefix}-app-lt"
  image_id               = data.aws_ssm_parameter.ubuntu.value
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.sg_app.id]
  user_data              = local.rendered_user_data
  key_name               = aws_key_pair.generated_key.key_name
  update_default_version = true
  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.disk_volume_size
      volume_type           = var.disk_volume_type
      encrypted             = var.disk_encrypted
      delete_on_termination = var.disk_delete_on_termination
    }
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  # Apply tags to instances launched from this template
  tags = merge(
    var.common_tags,
    {
      Name = "${var.name_prefix}-AppInstance"
    }
  )

  tag_specifications {
    resource_type = "volume"

    tags = merge(
      var.common_tags,
      {
        Name = "${var.name_prefix}-AppVolume"
      }
    )
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "app_asg" {
  desired_capacity          = var.asg_desired_capacity
  max_size                  = var.asg_max_size
  min_size                  = var.asg_min_size
  vpc_zone_identifier       = var.private_subnet_ids # Distribute across private subnets
  health_check_type         = "ELB"
  health_check_grace_period = var.asg_health_check_grace_period
  launch_template {
    id      = aws_launch_template.app_launch_template.id
    version = "$Latest"
  }

  target_group_arns = [var.app_target_group_arn]

  lifecycle {
    create_before_destroy = true
  }

  # Add tag dynamically to ASG instances
  dynamic "tag" {
    for_each = merge(
      var.common_tags,
      {
        Name = "${var.name_prefix}-AppInstance"
      }
    )

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}