locals {
  project     = var.project
  region      = var.aws_region
  name_prefix = var.project

  arch    = "x86_64" # Architecture type; x86_64 is used for t2, t3, t3a instances
  storage = "gp2"    # EBS volume type; gp2 = General Purpose SSD

  ami = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-${arch}-${storage}"


  policies = "${path.root}/modules/security/policies"

  scripts = "${path.root}/scripts"


}
