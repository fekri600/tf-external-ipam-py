state_bucket_name               = "nginx-backend-rsm"
state_bucket_versioning_enabled = true
state_bucket_sse_algorithm      = "AES256"
state_bucket_tags = {
  Name        = "Terraform Remote state management Bucket"
  Environment = "backend remote state management"
}

dynamodb_table_name     = "backend-d-db-table"
dynamodb_billing_mode   = "PAY_PER_REQUEST"
dynamodb_hash_key       = "LockID"
dynamodb_attribute_type = "S"
dynamodb_table_tags = {
  Name        = "Terraform Locks Table"
  Environment = "backend remote state management"
}

oidc_url             = "https://token.actions.githubusercontent.com"
oidc_client_id_list  = ["sts.amazonaws.com"]
oidc_thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

iam_role_name   = "TRUST_ROLE_GITHUB"
iam_policy_name = "github_permission_policy"
