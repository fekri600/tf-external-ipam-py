# modules/environment/main.tf
# 1. Launch Template
resource "aws_launch_template" "this" {
  name_prefix   = "${var.prefix}-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [var.security_group_id]
  user_data = base64encode(templatefile("${path.module}/user_data.sh.tmpl", {
    log_group_prefix = var.prefix,
    }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.prefix}-ec2"
    }
  }
}

resource "aws_autoscaling_group" "this" {
  name                      = "${var.prefix}-asg"
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
    value               = "${var.prefix}-asg"
    propagate_at_launch = true
  }
}


resource "aws_db_subnet_group" "this" {
  name       = "${var.prefix}-rds-subnet-group"
  subnet_ids = var.private_subnet_ids
}

resource "aws_db_instance" "this" {
  identifier             = "${var.prefix}-rds"
  engine                 = var.db_engine
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_storage
  username               = var.db_username
  password               = var.db_password
  vpc_security_group_ids = [var.security_group_id]
  skip_final_snapshot    = var.db_delete_snapshot

  db_subnet_group_name   = aws_db_subnet_group.this.name
  multi_az               = var.db_multi_az

  iam_database_authentication_enabled = var.db_iam_authentication
}


resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.prefix}-redis-subnet-group"
  subnet_ids = var.private_subnet_ids
}

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id = "${var.prefix}-redis"
  description = "redis replication group batataH"
  engine               = "redis"
  node_type            = var.redis_node_type
  num_cache_clusters   = 1
  subnet_group_name    = aws_elasticache_subnet_group.this.name
  security_group_ids   = [var.security_group_id]
}

resource "aws_iam_role" "ec2_role" {
  name               = "${var.prefix}-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Effect="Allow", Principal={ Service="ec2.amazonaws.com" }, Action="sts:AssumeRole" }]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.prefix}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}


