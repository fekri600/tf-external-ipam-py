
resource "aws_db_instance" "this" {
  identifier        = "rds-${var.prefix}-${var.environment}"
  engine            = var.database.engine
  instance_class    = var.database.instance_class
  allocated_storage = var.database.initial_storage

  username                            = var.database.username
  password                            = var.database.password
  vpc_security_group_ids              = var.db_security_group_ids
  skip_final_snapshot                 = var.database.delete_automated_backup
  multi_az                            = var.database.multi_az
  iam_database_authentication_enabled = var.database.iam_authentication
  backup_retention_period             = var.database.backup_retention_period # set to 7 or 30
  backup_window                       = var.database.backup_window           # optional, e.g., "03:00-04:00"
  db_subnet_group_name                = var.rds_subnet_group_name


  tags = {
    Name = "${var.prefix}-${var.environment}-rds"
  }
}
