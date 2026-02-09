terraform {
  required_version = "~> 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "s3_bucket" {
  source = "../../"

  bucket_name = "replace-with-unique-complete-bucket-name"

  force_destroy           = true
  versioning_enabled      = true
  sse_algorithm           = "AES256"
  bucket_key_enabled      = true
  object_ownership        = "BucketOwnerEnforced"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
    Example     = "complete"
  }
}

output "bucket_arn" {
  description = "Created bucket ARN."
  value       = module.s3_bucket.bucket_arn
}
