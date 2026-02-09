# terraform-s3-bucket

Reusable Terraform module for creating AWS S3 buckets with secure defaults: server-side encryption, versioning, public access blocking, and lifecycle rules.

## Features

- **Server-side encryption** - AES256 (default) or SSE-KMS with a customer-managed key
- **Versioning** - Enabled by default
- **Public access blocking** - All four block settings enabled
- **Lifecycle rules** - Optional noncurrent version expiration (default: 90 days)
- **Auto-naming** - Generates a globally unique bucket name from `name_prefix` + random suffix, or accepts an explicit `bucket_name`
- **Input validation** - Enforces lowercase `name_prefix`, valid `sse_algorithm` values, and requires `kms_key_arn` when using SSE-KMS

## Usage

### Minimal

```hcl
module "s3_bucket" {
  source = "path/to/module"

  name_prefix = "my-app"
}
```

### Full

```hcl
module "s3_bucket" {
  source = "path/to/module"

  name_prefix                        = "my-app"
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
```

## Requirements

| Name | Version |
|------|---------|
| Terraform | >= 1.7.0, < 2.0.0 |
| AWS provider | ~> 5.0 |
| Random provider | ~> 3.6 |

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name_prefix` | `string` | (required) | Lowercase prefix used when naming module resources (max 20 chars, lowercase alphanumeric and hyphens only) |
| `bucket_name` | `string` | `null` | S3 bucket name. If null, Terraform generates a globally unique name |
| `force_destroy` | `bool` | `false` | Whether Terraform can delete non-empty S3 buckets |
| `versioning_enabled` | `bool` | `true` | Whether S3 bucket versioning is enabled |
| `sse_algorithm` | `string` | `"AES256"` | Server-side encryption algorithm (`AES256` or `aws:kms`) |
| `kms_key_arn` | `string` | `null` | ARN of the KMS key for SSE-KMS encryption (required when `sse_algorithm` is `aws:kms`) |
| `noncurrent_version_expiration_days` | `number` | `90` | Days before noncurrent object versions expire. Set to `null` to disable the lifecycle rule |
| `tags` | `map(string)` | `{}` | Additional tags applied to all resources |

## Outputs

| Name | Description |
|------|-------------|
| `bucket_arn` | ARN of the S3 bucket |
| `bucket_id` | ID of the S3 bucket |
| `bucket_name` | Name of the S3 bucket |
| `bucket_region` | Region of the S3 bucket |

## Testing

This module includes two test files under `tests/`:

- **`defaults.tftest.hcl`** - Validates default variable values
- **`plan_mock.tftest.hcl`** - Plan-level assertions using mock providers

Run all tests:

```sh
terraform init
terraform test
```

Run a specific test file:

```sh
terraform test -filter=tests/plan_mock.tftest.hcl
```

## CI/CD

A GitHub Actions workflow (`.github/workflows/ci.yml`) runs on pushes to `main` and pull requests. It performs:

- `terraform fmt -check -recursive`
- `terraform validate`
- `terraform test` (both test files)
- TFLint with recursive scanning
