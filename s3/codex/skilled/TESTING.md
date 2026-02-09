# Testing Strategy

## Goals

- Catch syntax and structural issues quickly.
- Validate module behavior without creating real cloud resources.
- Continuously enforce checks in CI for pull requests and main branch pushes.

## Local Test Workflow

Run these from the module root:

```bash
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
terraform test
```

## Native Terraform Tests (`tests/*.tftest.hcl`)

- Use `mock_provider "aws"` to avoid AWS credentials and infrastructure costs.
- Use `command = plan` for fast checks of input-derived values and defaults.
- Use `command = apply` for computed attributes and set-style nested blocks (for encryption rules).
- Include negative tests for invalid configurations (for example, `aws:kms` without `kms_key_id`).

## CI Pipeline (`.github/workflows/terraform.yml`)

Jobs:

1. `validate`
   - Terraform format check
   - Terraform init (no backend)
   - Terraform validate
2. `test`
   - Terraform init (no backend)
   - Terraform native test suite
3. `security`
   - Trivy IaC scan
   - Checkov Terraform scan
