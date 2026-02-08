# Terraform Tests

## Plan-mode tests with mocks

```bash
terraform test -filter=tests/plan_mock.tftest.hcl
```

## Apply-mode integration test

This test provisions real AWS infrastructure and requires valid AWS credentials.

```bash
terraform test -filter=tests/integration_apply.tftest.hcl
```
