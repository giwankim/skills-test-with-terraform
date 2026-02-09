mock_provider "aws" {}
mock_provider "random" {}

# Test 1: Default uses prefix mode (bucket_name null, bucket_prefix null)
run "default_uses_prefix_mode" {
  command = apply

  assert {
    condition     = aws_s3_bucket.this.bucket != ""
    error_message = "Bucket should have a generated name."
  }
}

# Test 2: Explicit bucket name
run "explicit_bucket_name" {
  command = apply

  variables {
    bucket_name = "my-explicit-bucket"
  }

  assert {
    condition     = aws_s3_bucket.this.bucket == "my-explicit-bucket"
    error_message = "Bucket name should match the provided input."
  }
}

# Test 3: Versioning enabled by default
run "versioning_enabled_by_default" {
  command = plan

  assert {
    condition     = aws_s3_bucket_versioning.this.versioning_configuration[0].status == "Enabled"
    error_message = "Versioning should be Enabled by default."
  }
}

# Test 4: Versioning can be disabled
run "versioning_can_be_disabled" {
  command = plan

  variables {
    versioning_enabled = false
  }

  assert {
    condition     = aws_s3_bucket_versioning.this.versioning_configuration[0].status == "Suspended"
    error_message = "Versioning should be Suspended when disabled."
  }
}

# Test 5: Default encryption uses AES256 (set-type block, needs apply + for)
run "default_encryption_aes256" {
  command = apply

  assert {
    condition = alltrue([
      for rule in aws_s3_bucket_server_side_encryption_configuration.this.rule :
      alltrue([
        for config in rule.apply_server_side_encryption_by_default :
        config.sse_algorithm == "AES256"
      ])
    ])
    error_message = "Default encryption should use AES256."
  }
}

# Test 6: KMS encryption
run "kms_encryption" {
  command = apply

  variables {
    sse_algorithm     = "aws:kms"
    kms_master_key_id = "arn:aws:kms:us-east-1:123456789012:key/mock-key-id"
  }

  assert {
    condition = alltrue([
      for rule in aws_s3_bucket_server_side_encryption_configuration.this.rule :
      alltrue([
        for config in rule.apply_server_side_encryption_by_default :
        config.sse_algorithm == "aws:kms"
      ])
    ])
    error_message = "Encryption should use aws:kms."
  }
}

# Test 7: Public access blocked by default
run "public_access_blocked_by_default" {
  command = plan

  assert {
    condition     = aws_s3_bucket_public_access_block.this[0].block_public_acls == true
    error_message = "block_public_acls should be true."
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this[0].block_public_policy == true
    error_message = "block_public_policy should be true."
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this[0].ignore_public_acls == true
    error_message = "ignore_public_acls should be true."
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this[0].restrict_public_buckets == true
    error_message = "restrict_public_buckets should be true."
  }
}

# Test 8: Public access can be disabled (resource not created)
run "public_access_can_be_disabled" {
  command = plan

  variables {
    block_public_access = false
  }

  assert {
    condition     = length(aws_s3_bucket_public_access_block.this) == 0
    error_message = "Public access block should not be created when disabled."
  }
}

# Test 9: Lifecycle rules configured
run "lifecycle_rules_configured" {
  command = apply

  variables {
    lifecycle_rules = [
      {
        id     = "archive-rule"
        status = "Enabled"
        transitions = [
          {
            days          = 90
            storage_class = "STANDARD_IA"
          }
        ]
        expiration_days = 365
      }
    ]
  }

  assert {
    condition     = length(aws_s3_bucket_lifecycle_configuration.this[0].rule) == 1
    error_message = "Should have exactly one lifecycle rule."
  }

  assert {
    condition = anytrue([
      for rule in aws_s3_bucket_lifecycle_configuration.this[0].rule :
      rule.id == "archive-rule"
    ])
    error_message = "Lifecycle rule ID should be 'archive-rule'."
  }
}

# Test 10: No lifecycle when empty rules
run "no_lifecycle_when_empty" {
  command = plan

  assert {
    condition     = length(aws_s3_bucket_lifecycle_configuration.this) == 0
    error_message = "Lifecycle configuration should not be created with empty rules."
  }
}

# Test 11: Invalid SSE algorithm rejected
run "invalid_sse_algorithm_rejected" {
  command = plan

  variables {
    sse_algorithm = "INVALID"
  }

  expect_failures = [
    var.sse_algorithm,
  ]
}

# Test 12: Tags propagated to bucket
run "tags_propagated" {
  command = plan

  variables {
    tags = {
      Environment = "test"
      Project     = "my-project"
    }
  }

  assert {
    condition     = aws_s3_bucket.this.tags["Environment"] == "test"
    error_message = "Environment tag should be propagated."
  }

  assert {
    condition     = aws_s3_bucket.this.tags["Project"] == "my-project"
    error_message = "Project tag should be propagated."
  }
}
