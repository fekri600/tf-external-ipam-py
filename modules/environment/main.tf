# modules/environment/main.tf


data "aws_ssm_parameter" "ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-${var.arch}-gp2"
}

resource "aws_iam_role" "ec2_role" {
  name = "${var.prefix}-${var.environment}-ec2-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{ Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.prefix}-${var.environment}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# 1. Launch Template
resource "aws_launch_template" "this" {
  name_prefix            = "${var.prefix}-${var.environment}-lt-"
  image_id               = data.aws_ssm_parameter.ami.value
  instance_type          = var.instance_type
  vpc_security_group_ids = [var.security_group_id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh.tmpl", {
    log_group_prefix = "${var.prefix}-${var.environment}",
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
  desired_capacity          = 2
  max_size                  = 2
  min_size                  = 2
  vpc_zone_identifier       = var.private_subnet_ids
  health_check_type         = "EC2"
  health_check_grace_period = 60
  target_group_arns         = [var.target_group_arn]

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.prefix}-${var.environment}-asg"
    propagate_at_launch = true
  }
}


resource "aws_db_instance" "this" {
  identifier             = "rds-${var.prefix}-${var.environment}"
  engine                 = var.db_engine
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_storage
  username               = var.db_username
  password               = var.db_password
  vpc_security_group_ids = var.db_security_group_ids
  skip_final_snapshot    = var.db_delete_snapshot

  db_subnet_group_name = var.rds_subnet_group_name
  multi_az             = var.db_multi_az

  iam_database_authentication_enabled = var.db_iam_authentication

  tags = {
    Name = "${var.prefix}-${var.environment}-rds"
  }
}


resource "aws_elasticache_replication_group" "redis" {
  replication_group_id = "redis-${var.prefix}-${var.environment}"
  description          = "redis replication group for ${var.environment} environment"
  engine               = "redis"
  node_type            = var.redis_node_type
  num_cache_clusters   = 1
  subnet_group_name    = var.redis_subnet_group_name
  security_group_ids   = [var.redis_security_group_id]

  tags = {
    Name = "${var.prefix}-${var.environment}-redis"
  }
}




