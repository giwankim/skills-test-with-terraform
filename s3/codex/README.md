# Terraform S3 Module Exercise

This directory contains two versions of an AWS S3 Terraform module:

- `unskilled/`: a simpler baseline implementation.
- `skilled/`: a more complete, secure-by-default implementation with stronger validation and documentation.

## Repository Layout

```text
.
├── skilled/
│   ├── examples/
│   ├── tests/
│   ├── README.md
│   └── TESTING.md
└── unskilled/
    ├── tests/
    └── README.md
```

## What Is Different?

| Area | `unskilled` | `skilled` |
| --- | --- | --- |
| Public access controls | Single `block_public_access` toggle | Granular controls (`block_public_acls`, `block_public_policy`, etc.) |
| Encryption inputs | `sse_algorithm` + `kms_key_arn` | `sse_algorithm` + `kms_key_id` + `bucket_key_enabled` |
| Ownership controls | Not configured | Includes `aws_s3_bucket_ownership_controls` |
| Validation depth | Basic input validation | Expanded validation and preconditions |
| Examples/docs | Module README | Module README + minimal/complete examples + dedicated testing guide |

## Evaluation Findings

This comparison is evaluated against the criteria in the Terraform skill document:

- [terraform-skill `SKILL.md`](https://raw.githubusercontent.com/antonbabenko/terraform-skill/refs/heads/master/SKILL.md)

Focus areas from that rubric:

- Standard module structure
- Naming and code structure standards
- Testing strategy (including native test best practices)
- CI/CD staging and security scanning
- Security defaults and controls
- Version constraint strategy

### Score Summary

- `skilled`: **8.8 / 10**
- `unskilled`: **6.2 / 10**

### Detailed Comparison

| Criterion | `unskilled` | `skilled` | Assessment |
| --- | --- | --- | --- |
| Standard module structure | Core files + tests only | Core files + tests + `examples/minimal` + `examples/complete` | `skilled` better matches the recommended structure |
| Naming and scope | Uses singleton naming (`this`) correctly | Uses singleton naming (`this`) correctly | Tie |
| Variable and validation rigor | Good basics (`description`, `type`, defaults, limited validation) | Broader validation + more explicit nullability controls | `skilled` has stronger guardrails |
| Native Terraform tests | `mock_provider` + plan assertions (2 runs) | `mock_provider` + plan/apply + negative-path test (4 runs) | `skilled` is more aligned with test best practices |
| CI/CD workflow | Single pipeline with fmt/init/validate/test | Multi-stage pipeline (`validate`, `test`, `security`) with `tflint`, Trivy, and Checkov | `skilled` aligns better with CI/CD and security guidance |
| Security posture in module | Secure defaults, but single public-access toggle and no ownership controls | Secure defaults with granular public-access controls + ownership controls + bucket key option | `skilled` is stronger by default |
| Version constraints | `>= 1.7.0`, `>= 5.0` (open-ended) | `~> 1.9`, `~> 5.0` (pinned ranges) | `skilled` aligns with recommended version strategy |

### Validation Results Used in This Evaluation

Commands executed locally in each module directory:

```bash
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
terraform test -verbose
```

Observed outcomes:

- Both `unskilled` and `skilled` passed `fmt`, `validate`, and native tests.
- `skilled` test suite covered more scenarios (defaults, set-style encryption assertions via `apply`, tags, and negative KMS precondition).

## Prerequisites

- Terraform `1.9.x` (works for both modules)
- AWS provider `5.x`

Note: Native tests use `mock_provider "aws"`, so tests do not require AWS credentials.

## Quick Start

### Validate and test `unskilled`

```bash
cd unskilled
terraform init -backend=false
terraform validate
terraform test -verbose
```

### Validate and test `skilled`

```bash
cd skilled
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
terraform test -verbose
```

## Module Documentation

- `unskilled/README.md`
- `skilled/README.md`
- `skilled/TESTING.md`

For usage examples of the `skilled` module, see:

- `skilled/examples/minimal/main.tf`
- `skilled/examples/complete/main.tf`
