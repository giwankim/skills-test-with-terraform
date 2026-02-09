module "s3_bucket" {
  source = "../.."

  name_prefix                        = var.name_prefix
  bucket_name                        = "my-custom-bucket-name"
  force_destroy                      = true
  versioning_enabled                 = true
  sse_algorithm                      = "aws:kms"
  kms_key_arn                        = "arn:aws:kms:us-east-1:123456789012:key/example-key-id"
  noncurrent_version_expiration_days = 30

  tags = {
    Environment = "production"
  }
}
