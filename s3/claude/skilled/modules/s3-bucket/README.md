# S3 Bucket Module

Reusable Terraform module for creating AWS S3 buckets with secure defaults.

## Usage

```hcl
module "s3_bucket" {
  source = "../../modules/s3-bucket"

  bucket_prefix = "my-app-"

  tags = {
    Environment = "production"
    Project     = "my-app"
  }
}
```

## Features

- Versioning enabled by default
- Server-side encryption (AES256 or KMS)
- Public access blocked by default
- Configurable lifecycle rules
- Optional access logging

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `bucket_name` | Explicit bucket name | `string` | `null` | no |
| `bucket_prefix` | Bucket name prefix | `string` | `null` | no |
| `force_destroy` | Allow non-empty bucket destruction | `bool` | `false` | no |
| `versioning_enabled` | Enable versioning | `bool` | `true` | no |
| `sse_algorithm` | Encryption algorithm (AES256 or aws:kms) | `string` | `"AES256"` | no |
| `kms_master_key_id` | KMS key ID for SSE-KMS | `string` | `null` | no |
| `bucket_key_enabled` | Enable S3 Bucket Key for KMS | `bool` | `true` | no |
| `block_public_access` | Block all public access | `bool` | `true` | no |
| `lifecycle_rules` | Lifecycle rules | `list(object)` | `[]` | no |
| `logging_target_bucket` | Target bucket for access logging | `string` | `null` | no |
| `logging_target_prefix` | Log object prefix | `string` | `"logs/"` | no |
| `tags` | Tags for the bucket | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `bucket_id` | The name of the bucket |
| `bucket_arn` | The ARN of the bucket |
| `bucket_domain_name` | The bucket domain name |
| `bucket_regional_domain_name` | The region-specific domain name |
| `bucket_region` | The AWS region |
