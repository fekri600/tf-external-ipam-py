project            = "nginx"
aws_region         = "us-east-1"
environment        = "dev"
vpc_cidr           = "10.0.0.0/16"
public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets    = ["10.0.3.0/24", "10.0.4.0/24"]
availability_zones = ["us-east-1a", "us-east-1b"]
alert_email        = "admin@example.com"
db_engine          = "mysql"

# Staging environment variables
stag_instance_type         = "t2.micro"
stag_db_instance_class     = "db.t3.micro"
stag_db_init_storage       = 20
stag_db_username           = "admin"
stag_db_password           = "your-secure-password"
stag_db_delete_snapshot    = true
stag_db_multi_az           = false
stag_db_iam_authentication = false
stag_redis_node_type       = "cache.t3.micro"

# Production environment variables
prod_instance_type         = "t2.small"
prod_db_instance_class     = "db.t3.small"
prod_db_init_storage       = 50
prod_db_username           = "admin"
prod_db_password           = "your-secure-password"
prod_db_delete_snapshot    = false
prod_db_multi_az           = true
prod_db_iam_authentication = true
prod_redis_node_type       = "cache.t3.small" 