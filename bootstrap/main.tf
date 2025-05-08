module "backend_setup" {
  source = "../modules/backend_setup"
  # any needed vars
}

module "oidc" {
  source            = "../modules/oidc"
  state_bucket_name = module.backend_setup.bucket_name
}
