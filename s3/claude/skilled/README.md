# S3 Bucket Module (with skills)

Terraform S3 bucket module created with the assistance of Claude Code agent skills (`terraform-skill`). Part of a comparison project evaluating how agent skills affect Terraform module quality - see the [parent README](../README.md) for the full analysis.

## Project Structure

```
with/
  modules/
    s3-bucket/
      main.tf              # 6 resources: bucket, versioning, SSE, public access, lifecycle, logging
      variables.tf         # 12 input variables
      outputs.tf           # 5 outputs
      versions.tf          # Terraform ~> 1.9, AWS ~> 5.0
      README.md            # Module documentation
      examples/
        minimal/           # Basic usage with defaults
        complete/          # Multi-module composition (log bucket + main bucket)
      tests/
        s3_bucket.tftest.hcl  # 12 test runs using mock providers
```

## Module Features

- **Server-side encryption** - AES256 (default) or KMS with bucket key support
- **Versioning** - enabled by default, can be suspended
- **Public access blocking** - all four settings enabled by default (can be toggled)
- **Lifecycle rules** - dynamic multi-rule support with transitions, expiration, and prefix filters
- **Access logging** - optional, with configurable target bucket and prefix
- **Flexible naming** - explicit `bucket_name` or AWS-generated via `bucket_prefix`

## Usage

```hcl
module "s3_bucket" {
  source = "./modules/s3-bucket"

  bucket_prefix = "my-app-"

  lifecycle_rules = [
    {
      id              = "archive"
      transitions     = [{ days = 90, storage_class = "STANDARD_IA" }]
      expiration_days = 365
    }
  ]

  tags = {
    Environment = "production"
    Project     = "my-app"
  }
}
```

See `modules/s3-bucket/examples/` for minimal and complete usage examples.

## Testing

The module includes 12 native Terraform tests using mock providers (no AWS credentials required):

```sh
cd modules/s3-bucket
terraform init
terraform test
```

Tests cover: default configuration, explicit naming, versioning toggle, AES256 and KMS encryption, public access blocking toggle, lifecycle rule creation and absence, input validation rejection (`expect_failures`), and tag propagation.

## Known Issues

1. **Missing `filter {}` block** - lifecycle rules without a prefix produce no `filter {}` block, which triggers AWS provider warnings that will become errors
2. **Incorrect `[0]` indexing on sets** - tests use `[0]` on `versioning_configuration` (a set type); works with mocks but is not semantically correct
3. **Unused `random` provider** - declared in `versions.tf` but never referenced in module code
4. **No default tags** - tagging consistency depends entirely on callers
5. **No CI/CD or linting** configuration
6. **Public access can be disabled** - the `block_public_access` toggle creates unnecessary security risk surface
