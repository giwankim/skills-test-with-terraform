mock_provider "aws" {}

run "defaults" {
  command = plan

  variables {
    bucket_name = "example-module-defaults-bucket-123456"
  }

  assert {
    condition     = aws_s3_bucket.this.bucket == "example-module-defaults-bucket-123456"
    error_message = "Bucket name should match the input variable."
  }

  assert {
    condition     = aws_s3_bucket_versioning.this.versioning_configuration[0].status == "Enabled"
    error_message = "Versioning should be enabled by default."
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this.block_public_acls
    error_message = "Public ACLs should be blocked by default."
  }

  assert {
    condition     = one(one(aws_s3_bucket_server_side_encryption_configuration.this.rule).apply_server_side_encryption_by_default).sse_algorithm == "AES256"
    error_message = "Default server-side encryption should use AES256."
  }
}

run "custom_settings" {
  command = plan

  variables {
    bucket_name         = "example-module-custom-bucket-123456"
    versioning_enabled  = false
    block_public_access = false
    sse_algorithm       = "aws:kms"
    kms_key_arn         = "arn:aws:kms:us-east-1:111122223333:key/11111111-2222-3333-4444-555555555555"
    tags = {
      Environment = "test"
    }
  }

  assert {
    condition     = aws_s3_bucket_versioning.this.versioning_configuration[0].status == "Suspended"
    error_message = "Versioning should be suspended when versioning_enabled is false."
  }

  assert {
    condition     = !aws_s3_bucket_public_access_block.this.block_public_acls
    error_message = "Public ACL blocking should be disabled when block_public_access is false."
  }

  assert {
    condition     = one(one(aws_s3_bucket_server_side_encryption_configuration.this.rule).apply_server_side_encryption_by_default).kms_master_key_id == "arn:aws:kms:us-east-1:111122223333:key/11111111-2222-3333-4444-555555555555"
    error_message = "KMS key ARN should propagate to encryption configuration."
  }
}
