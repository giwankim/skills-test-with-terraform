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

run "defaults_lifecycle_rule_created" {
  command = plan

  variables {
    name_prefix = "test"
    bucket_name = "mock-bucket"
  }

  assert {
    condition     = length(aws_s3_bucket_lifecycle_configuration.this) == 1
    error_message = "Lifecycle configuration should exist when noncurrent_version_expiration_days is set."
  }

  assert {
    condition     = aws_s3_bucket_lifecycle_configuration.this[0].rule[0].noncurrent_version_expiration[0].noncurrent_days == 90
    error_message = "Noncurrent version expiration should default to 90 days."
  }
}

run "defaults_no_lifecycle_when_null" {
  command = plan

  variables {
    name_prefix                        = "test"
    bucket_name                        = "mock-bucket"
    noncurrent_version_expiration_days = null
  }

  assert {
    condition     = length(aws_s3_bucket_lifecycle_configuration.this) == 0
    error_message = "Lifecycle configuration should not exist when noncurrent_version_expiration_days is null."
  }
}
