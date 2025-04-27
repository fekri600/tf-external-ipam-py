environment        = "network"
project            = "360mom"
aws_region         = "us-east-1"
vpc_cidr           = "10.0.0.0/16"
public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets    = ["10.0.11.0/24", "10.0.12.0/24"]
availability_zones = ["us-east-1a", "us-east-1b"]
alert_email        = "alerts@example.com"
db_engine          = "mysql"

stag_instance_type         = "t3.micro"
stag_ami_id                = "ami-0abcd1234abcd1234"
stag_db_instance_class     = "db.t3.micro"
stag_db_init_storage       = 20
stag_db_username           = "staging_user"
stag_db_password           = "staging_pass"
stag_redis_node_type       = "cache.t3.micro"
stag_db_delete_snapshot    = true
stag_db_iam_authentication = false
stag_db_multi_az           = true



prod_instance_type         = "t3.micro"
prod_ami_id                = "ami-0abcd1234abcd1234"
prod_db_instance_class     = "db.t3.micro"
prod_db_init_storage       = 50
prod_db_username           = "staging_user"
prod_db_password           = "staging_pass"
prod_redis_node_type       = "cache.t3.micro"
prod_db_delete_snapshot    = true
prod_db_iam_authentication = false
prod_db_multi_az           = true




