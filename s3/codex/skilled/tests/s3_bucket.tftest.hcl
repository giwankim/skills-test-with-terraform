mock_provider "aws" {}

run "plan_with_secure_defaults" {
  command = plan

  variables {
    bucket_name = "test-plan-secure-defaults-bucket"
  }

  assert {
    condition     = aws_s3_bucket.this.bucket == "test-plan-secure-defaults-bucket"
    error_message = "Bucket name should match input."
  }

  assert {
    condition     = aws_s3_bucket_versioning.this.versioning_configuration[0].status == "Enabled"
    error_message = "Versioning should be enabled by default."
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this.block_public_policy
    error_message = "Public bucket policies should be blocked by default."
  }
}

run "apply_with_default_encryption" {
  command = apply

  variables {
    bucket_name = "test-apply-default-encryption-bucket"
  }

  assert {
    condition = alltrue([
      for rule in aws_s3_bucket_server_side_encryption_configuration.this.rule :
      alltrue([
        for config in rule.apply_server_side_encryption_by_default :
        config.sse_algorithm == "AES256"
      ])
    ])
    error_message = "Default encryption algorithm should be AES256."
  }

  assert {
    condition = alltrue([
      for rule in aws_s3_bucket_server_side_encryption_configuration.this.rule :
      rule.bucket_key_enabled == true
    ])
    error_message = "Bucket key should be enabled by default."
  }
}

run "plan_applies_tags" {
  command = plan

  variables {
    bucket_name = "test-plan-tags-bucket"
    tags = {
      ManagedBy = "terraform"
      Team      = "platform"
    }
  }

  assert {
    condition     = aws_s3_bucket.this.tags["ManagedBy"] == "terraform"
    error_message = "ManagedBy tag should be set on the bucket."
  }
}

run "plan_fails_when_kms_key_missing" {
  command = plan

  variables {
    bucket_name   = "test-plan-kms-failure-bucket"
    sse_algorithm = "aws:kms"
  }

  expect_failures = [
    aws_s3_bucket_server_side_encryption_configuration.this
  ]
}
