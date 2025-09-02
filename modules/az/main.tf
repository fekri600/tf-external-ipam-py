# Get AZs in us-east-1
data "aws_availability_zones" "this" {
  state = "available"
}


