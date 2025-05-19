locals {
  project     = var.project_settings.project
  region      = var.project_settings.aws_region
  name_prefix = var.project_settings.project

  # arch    = var.launch_template.architecture # Architecture type; x86_64 is used for t2, t3, t3a instances
  # storage = var.launch_template.storage   # EBS volume type; gp2 = General Purpose SSD

  # ami = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-${arch}-${storage}"
  #ami_path = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm"


  policies = "${path.root}/policies"

  scripts = "${path.root}/scripts"


}
