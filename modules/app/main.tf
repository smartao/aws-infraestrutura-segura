locals {
  #rendered_user_data = base64encode(file("${path.module}/scripts/${var.app_user_data}"))
  rendered_user_data = filebase64("${path.module}/scripts/${var.app_user_data}")
}

data "aws_ssm_parameter" "ubuntu" {
  name = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
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
  vpc_security_group_ids = [var.sg_app_id]
  user_data              = local.rendered_user_data
  key_name               = aws_key_pair.generated_key.key_name

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