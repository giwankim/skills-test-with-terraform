# Terraform AWS S3 Bucket Module

Reusable Terraform module to provision an AWS S3 bucket with secure defaults and built-in test coverage.

## Features

- Creates an S3 bucket with configurable name and tags.
- Enables versioning by default.
- Enables server-side encryption by default (`AES256`).
- Blocks all public access by default.
- Supports KMS encryption (`aws:kms`) with validation for `kms_key_arn`.

## Requirements

| Name | Version |
| --- | --- |
| Terraform | `>= 1.7.0` |
| AWS Provider | `>= 5.0` |

## Usage

### Basic Example

```hcl
module "logs_bucket" {
  source = "./"

  bucket_name = "my-company-logs-bucket"

  tags = {
    Environment = "prod"
    Owner       = "platform"
  }
}
```

### KMS Encryption Example

```hcl
module "secure_bucket" {
  source = "./"

  bucket_name   = "my-company-secure-bucket"
  sse_algorithm = "aws:kms"
  kms_key_arn   = "arn:aws:kms:us-east-1:111122223333:key/11111111-2222-3333-4444-555555555555"
}
```

## Inputs

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `bucket_name` | `string` | n/a | Globally unique S3 bucket name. Must be 3-63 chars, lowercase letters, numbers, dots, or hyphens. |
| `force_destroy` | `bool` | `false` | Delete all objects when destroying the bucket. |
| `versioning_enabled` | `bool` | `true` | Enable (`true`) or suspend (`false`) bucket versioning. |
| `block_public_access` | `bool` | `true` | Enable or disable all public access block settings. |
| `sse_algorithm` | `string` | `"AES256"` | Encryption algorithm (`AES256` or `aws:kms`). |
| `kms_key_arn` | `string` | `null` | KMS key ARN required when `sse_algorithm = "aws:kms"`. |
| `tags` | `map(string)` | `{}` | Tags applied to module resources. |

## Outputs

| Name | Description |
| --- | --- |
| `bucket_id` | S3 bucket ID. |
| `bucket_arn` | S3 bucket ARN. |
| `bucket_name` | S3 bucket name. |

## Testing

Native Terraform tests are defined in `tests/s3_bucket.tftest.hcl` and use `mock_provider "aws"` so they do not need AWS credentials.

The suite validates:

- Secure defaults (versioning/public access/encryption).
- Custom configuration behavior (versioning off, public access off, KMS key wiring).

Run tests locally:

```bash
terraform init -backend=false
terraform validate
terraform test -verbose
```

## CI Pipeline

GitHub Actions workflow: `.github/workflows/terraform-ci.yml`

On pull requests and pushes to `main`, CI runs:

```bash
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
terraform test -verbose
```
