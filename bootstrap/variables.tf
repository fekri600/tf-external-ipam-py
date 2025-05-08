variable "state_bucket_name" {
  description = "S3 bucket name for Terraform state"
  type        = string
}

variable "state_bucket_versioning_enabled" {
  description = "Enable versioning on S3 bucket"
  type        = bool
}

variable "state_bucket_sse_algorithm" {
  description = "SSE algorithm for S3 bucket encryption"
  type        = string
}

variable "state_bucket_tags" {
  description = "Tags for S3 bucket"
  type        = map(string)
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name for state locking"
  type        = string
}

variable "dynamodb_billing_mode" {
  description = "Billing mode for DynamoDB table"
  type        = string
}

variable "dynamodb_hash_key" {
  description = "Hash key attribute name for DynamoDB table"
  type        = string
}

variable "dynamodb_attribute_type" {
  description = "Type for hash key attribute"
  type        = string
}

variable "dynamodb_table_tags" {
  description = "Tags for DynamoDB table"
  type        = map(string)
}

variable "oidc_url" {
  description = "OIDC provider URL"
  type        = string
}

variable "oidc_client_id_list" {
  description = "OIDC client IDs"
  type        = list(string)
}

variable "oidc_thumbprint_list" {
  description = "OIDC thumbprint list"
  type        = list(string)
}

variable "iam_role_name" {
  description = "IAM role name"
  type        = string
}

variable "iam_policy_name" {
  description = "IAM policy name"
  type        = string
}
