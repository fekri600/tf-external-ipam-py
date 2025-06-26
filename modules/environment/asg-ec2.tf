# modules/environment/main.tf
data "aws_ssm_parameter" "ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-${var.launch_template.architecture}-${var.launch_template.storage}"
}


data "aws_caller_identity" "current" {}


resource "aws_iam_role" "ec2_role" {
  name               = "${var.prefix}-${var.environment}-ec2-role"
  assume_role_policy = file("${var.policies_path}/ec2_assume_role_policy.json")
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "rds_connect_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.rds_connect.arn
}

resource "aws_iam_policy" "rds_connect" {
  name = "${var.prefix}-${var.environment}-rds-connect"

  policy = templatefile("${var.policies_path}/rds_connect_policy.json", {
    region         = var.project_settings.aws_region,
    account_id     = data.aws_caller_identity.current.account_id,
    db_resource_id = aws_db_instance.this.resource_id,
    db_username    = var.database.username
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.prefix}-${var.environment}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# 1. Launch Template
resource "aws_launch_template" "this" {
  name_prefix = "${var.prefix}-${var.environment}-lt-"
  image_id    = data.aws_ssm_parameter.ami.value

  instance_type          = var.launch_template.instance_type
  vpc_security_group_ids = [var.ec2_security_group_id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  user_data = base64encode(templatefile("${var.scripts_path}/user_data.sh.tmpl", {
    log_group_prefix = var.environment,
    region           = var.project_settings.aws_region
  }))



  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.prefix}-${var.environment}-ec2"
    }
  }
}

resource "aws_autoscaling_group" "this" {
  name                      = "${var.prefix}-${var.environment}-asg"
  vpc_zone_identifier       = var.private_subnet_ids
  target_group_arns         = [var.target_group_arn]
  desired_capacity          = var.autoscaling.desired_capacity
  max_size                  = var.autoscaling.max_size
  min_size                  = var.autoscaling.min_size
  health_check_type         = var.autoscaling.health_check_type
  health_check_grace_period = var.autoscaling.health_check_grace_period


  launch_template {
    id      = aws_launch_template.this.id
    version = var.autoscaling.version
  }

  tag {
    key                 = "Name"
    value               = "${var.prefix}-${var.environment}-ec2"
    propagate_at_launch = var.autoscaling.propagate_at_launch
  }
}
