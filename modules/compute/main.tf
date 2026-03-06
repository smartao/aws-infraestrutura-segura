locals {
  #rendered_user_data = base64encode(file("${path.module}/scripts/${var.app_user_data}"))
  rendered_user_data = filebase64("${path.module}/scripts/${var.app_user_data}")
}

data "aws_ssm_parameter" "ubuntu" {
  name = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

resource "aws_key_pair" "generated_key" {
  key_name   = "${var.name_prefix}-Bastion-key"
  public_key = var.public_key
}

# Bastion Host
resource "aws_instance" "bastion" {
  ami                         = data.aws_ssm_parameter.ubuntu.value
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_ids[0] # Place Bastion in the first public subnet
  vpc_security_group_ids      = [var.sg_bastion_id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.generated_key.key_name

  root_block_device {
    volume_size           = var.disk_volume_size
    volume_type           = var.disk_volume_type
    encrypted             = var.disk_encrypted
    delete_on_termination = var.disk_delete_on_termination

    tags = {
      Name      = "${var.name_prefix}-BastionHost-RootVolume"
      ManagedBy = "Terraform"
    }
  }

  tags = {
    Name = "${var.name_prefix}-BastionHost"
  }
}


# Application Load Balancer
resource "aws_lb" "internal_alb" {
  name               = "${var.name_prefix}-internal-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [var.sg_alb_id]
  subnets            = var.private_subnet_ids
}

resource "aws_lb_target_group" "app_target_group" {
  name     = "${var.name_prefix}-app-tg"
  port     = var.app_port
  protocol = var.app_protocol
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = var.app_protocol
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
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

# Application EC2 Instances (via Launch Template and Auto Scaling Group)
resource "aws_launch_template" "app_launch_template" {
  name_prefix            = "${var.name_prefix}-app-lt"
  image_id               = data.aws_ssm_parameter.ubuntu.value
  instance_type          = var.instance_type
  vpc_security_group_ids = [var.sg_app_id]
  user_data              = local.rendered_user_data
  key_name               = aws_key_pair.generated_key.key_name

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
  desired_capacity    = var.asg_desired_capacity
  max_size            = var.asg_max_size
  min_size            = var.asg_min_size
  vpc_zone_identifier = var.private_subnet_ids # Distribute across private subnets

  launch_template {
    id      = aws_launch_template.app_launch_template.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app_target_group.arn]

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