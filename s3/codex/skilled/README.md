# terraform-aws-s3-bucket

Terraform module to provision a secure-by-default AWS S3 bucket.

## Features

- Creates one S3 bucket.
- Enables server-side encryption (AES256 by default, optional KMS).
- Configures versioning.
- Applies public access block controls.
- Configures object ownership controls.

## Usage

```hcl
module "logs_bucket" {
  source = "path/to/this/module"

  bucket_name = "my-org-logs-bucket"

  tags = {
    Environment = "prod"
    ManagedBy   = "terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucket_name | Name of the S3 bucket to create. | `string` | n/a | yes |
| force_destroy | Whether to allow deletion of non-empty bucket contents when destroying the bucket. | `bool` | `false` | no |
| versioning_enabled | Whether to enable bucket object versioning. | `bool` | `true` | no |
| sse_algorithm | Default server-side encryption algorithm for bucket objects. Valid values: AES256 or aws:kms. | `string` | `"AES256"` | no |
| kms_key_id | KMS key ID or ARN to use when sse_algorithm is aws:kms. Leave null for AES256. | `string` | `null` | no |
| bucket_key_enabled | Whether to enable S3 Bucket Keys for KMS encryption cost optimization. | `bool` | `true` | no |
| object_ownership | Object ownership setting for the bucket. | `string` | `"BucketOwnerEnforced"` | no |
| block_public_acls | Whether Amazon S3 should block public ACLs for this bucket. | `bool` | `true` | no |
| block_public_policy | Whether Amazon S3 should block public bucket policies for this bucket. | `bool` | `true` | no |
| ignore_public_acls | Whether Amazon S3 should ignore public ACLs for this bucket. | `bool` | `true` | no |
| restrict_public_buckets | Whether Amazon S3 should restrict public bucket policies for this bucket. | `bool` | `true` | no |
| tags | Tags to apply to resources that support tags. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket_id | ID (name) of the created S3 bucket. |
| bucket_arn | ARN of the created S3 bucket. |
| bucket_domain_name | Bucket domain name. |
| bucket_regional_domain_name | Regional bucket domain name. |

## Examples

- `examples/minimal` shows the smallest working use case.
- `examples/complete` shows a fuller configuration.

## Testing Strategy

This module uses a layered strategy:

1. Static checks: `terraform fmt -check -recursive`, `terraform validate`, `tflint`
2. Native Terraform tests: `terraform test` with `mock_provider "aws"` for cost-free validation
3. CI pipeline: GitHub Actions runs validation, tests, and security scans (Trivy + Checkov)

For details, see `TESTING.md`.
