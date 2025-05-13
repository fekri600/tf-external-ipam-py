# modules/environment/main.tf
data "aws_ssm_parameter" "ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-${var.launch_template.architecture}-${var.launch_template.storage}"
}
resource "aws_iam_role" "ec2_role" {
  name               = "${var.prefix}-${var.environment}-ec2-role"
  assume_role_policy = file("${var.policies_path}/ec2_assume_role_policy.json")
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
  image_id               =  data.aws_ssm_parameter.ami.value

  instance_type          = var.launch_template.instance_type
  vpc_security_group_ids = [var.ec2_security_group_id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  user_data = base64encode(templatefile("${var.scripts_path}/user_data.sh.tmpl", {
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
    value               = "${var.prefix}-${var.environment}-asg"
    propagate_at_launch = var.autoscaling.propagate_at_launch
  }
}


resource "aws_db_instance" "this" {
  identifier             = "rds-${var.prefix}-${var.environment}"
  engine                 = var.database.engine
  instance_class         = var.database.instance_class
  allocated_storage      = var.database.initial_storage

  username               = var.database.username
  password               = var.database.password
  vpc_security_group_ids = var.db_security_group_ids
  skip_final_snapshot = var.database.delete_automated_backup
  multi_az            = var.database.multi_az
  iam_database_authentication_enabled = var.database.iam_authentication

  db_subnet_group_name = var.rds_subnet_group_name
  

  tags = {
    Name = "${var.prefix}-${var.environment}-rds"
  }
}


resource "aws_elasticache_replication_group" "redis" {
  replication_group_id = "redis-${var.prefix}-${var.environment}"
  description          = "redis replication group for ${var.environment} environment"
  node_type            = var.redis.node_type
  subnet_group_name    = var.redis_subnet_group_name
  security_group_ids   = [var.redis_security_group_id]
  engine             = var.redis.redis_settings.engine
  num_cache_clusters = var.redis.redis_settings.num_cache_clusters

  tags = {
    Name = "${var.prefix}-${var.environment}-redis"
  }
}




