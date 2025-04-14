region            = "us-east-1"
#backend_bucket    = "my-terraform-backend-bucket"
#lock_table        = "my-lock-table"

# staging
# EC2 instances
instance_type     = "t2.micro"
ami_id            = "ami-0c2b8ca1dad447f8a"

# production
# EC2 instances

instance_type     = "t2.micro"
ami_id            = "ami-0c2b8ca1dad447f8a"


vpc_cidr          = "10.0.0.0/16"
public_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets   = ["10.0.101.0/24", "10.0.102.0/24"]
availability_zones = ["us-east-1a", "us-east-1b"]
db_engine         = "mysql"
db_instance_class = "db.t3.micro"
db_storage        = 20
db_username       = "admin"
db_password       = "mysecretpassword"
db_parameter_group = "default.mysql8.0"
redis_node_type   = "cache.t3.micro"
