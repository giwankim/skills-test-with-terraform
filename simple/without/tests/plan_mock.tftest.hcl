mock_provider "aws" {
  mock_resource "aws_s3_bucket" {
    defaults = {
      arn    = "arn:aws:s3:::mock-bucket"
      bucket = "mock-bucket"
      id     = "mock-bucket"
      region = "us-east-1"
    }
  }
}

mock_provider "random" {}

run "plan_defaults" {
  command = plan

  variables {
    name_prefix = "test"
    bucket_name = "mock-bucket"
  }

  assert {
    condition     = aws_s3_bucket.this.bucket == "mock-bucket"
    error_message = "Bucket name should match the configured bucket_name."
  }

  assert {
    condition     = aws_s3_bucket.this.force_destroy == false
    error_message = "force_destroy should default to false."
  }

  assert {
    condition     = one(aws_s3_bucket_versioning.this.versioning_configuration[*].status) == "Enabled"
    error_message = "Versioning should default to Enabled."
  }

  assert {
    condition     = one(one(aws_s3_bucket_server_side_encryption_configuration.this.rule[*].apply_server_side_encryption_by_default)[*].sse_algorithm) == "AES256"
    error_message = "SSE algorithm should default to AES256."
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this.block_public_acls == true
    error_message = "block_public_acls should be true."
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this.block_public_policy == true
    error_message = "block_public_policy should be true."
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this.ignore_public_acls == true
    error_message = "ignore_public_acls should be true."
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this.restrict_public_buckets == true
    error_message = "restrict_public_buckets should be true."
  }
}

run "plan_with_kms" {
  command = plan

  variables {
    name_prefix   = "test"
    bucket_name   = "mock-bucket"
    sse_algorithm = "aws:kms"
    kms_key_arn   = "arn:aws:kms:us-east-1:123456789012:key/mock-key-id"
  }

  assert {
    condition     = one(one(aws_s3_bucket_server_side_encryption_configuration.this.rule[*].apply_server_side_encryption_by_default)[*].sse_algorithm) == "aws:kms"
    error_message = "SSE algorithm should be aws:kms when configured."
  }

  assert {
    condition     = one(one(aws_s3_bucket_server_side_encryption_configuration.this.rule[*].apply_server_side_encryption_by_default)[*].kms_master_key_id) == "arn:aws:kms:us-east-1:123456789012:key/mock-key-id"
    error_message = "KMS key ARN should match the configured kms_key_arn."
  }
}

run "plan_versioning_disabled" {
  command = plan

  variables {
    name_prefix        = "test"
    bucket_name        = "mock-bucket"
    versioning_enabled = false
  }

  assert {
    condition     = one(aws_s3_bucket_versioning.this.versioning_configuration[*].status) == "Suspended"
    error_message = "Versioning should be Suspended when disabled."
  }
}
