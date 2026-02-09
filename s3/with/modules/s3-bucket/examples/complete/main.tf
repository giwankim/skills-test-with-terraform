module "log_bucket" {
  source = "../../"

  bucket_prefix       = "logs-${var.environment}-"
  force_destroy       = true
  block_public_access = true

  tags = {
    Environment = var.environment
    Purpose     = "logging"
  }
}

module "s3_bucket" {
  source = "../../"

  bucket_prefix       = "complete-${var.environment}-"
  force_destroy       = true
  versioning_enabled  = true
  sse_algorithm       = "AES256"
  block_public_access = true

  lifecycle_rules = [
    {
      id     = "archive-old-objects"
      status = "Enabled"
      transitions = [
        {
          days          = 90
          storage_class = "STANDARD_IA"
        },
        {
          days          = 180
          storage_class = "GLACIER"
        },
      ]
      expiration_days = 365
    },
    {
      id              = "clean-temp"
      status          = "Enabled"
      prefix          = "tmp/"
      expiration_days = 7
    },
  ]

  logging_target_bucket = module.log_bucket.bucket_id
  logging_target_prefix = "s3-access-logs/"

  tags = {
    Environment = var.environment
    Example     = "complete"
  }
}
