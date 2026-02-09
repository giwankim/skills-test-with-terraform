# Terraform Skill Benchmark Workspace

This repository benchmarks Terraform output quality across:

- Two stacks: `s3` and `three-tier`
- Two agents: `claude` and `codex`
- Two modes: `skilled` (with `terraform-skill`) and `unskilled` (baseline)

That gives **8 implementation directories** that can be compared side by side.

## Comparison Matrix

| Stack | Agent | Skilled | Unskilled |
|---|---|---|---|
| `s3` | `claude` | `s3/claude/skilled` | `s3/claude/unskilled` |
| `s3` | `codex` | `s3/codex/skilled` | `s3/codex/unskilled` |
| `three-tier` | `claude` | `three-tier/claude/skilled` | `three-tier/claude/unskilled` |
| `three-tier` | `codex` | `three-tier/codex/skilled` | `three-tier/codex/unskilled` |

## Repository Layout

```text
.
├── s3/
│   ├── claude/
│   │   ├── skilled/
│   │   └── unskilled/
│   ├── codex/
│   │   ├── skilled/
│   │   └── unskilled/
│   └── three-tier/
│       ├── claude/   # evaluation notes
│       └── codex/    # evaluation notes
├── three-tier/
│   ├── claude/
│   │   ├── skilled/
│   │   └── unskilled/
│   └── codex/
│       ├── skilled/
│       └── unskilled/
└── README.md
```

## What Each Implementation Contains

Most implementation folders include:

- Terraform module/configuration files (`main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`)
- Native Terraform tests (`*.tftest.hcl`)
- Example usages (`examples/minimal`, sometimes `examples/complete`)
- CI workflows (`.github/workflows`)

There are **22 Terraform native test files** across `s3/` and `three-tier/`.

## Tooling Requirements

Version constraints vary by directory (for example: `>= 1.7`, `~> 1.9`, and `>= 1.11`), so check each target's `versions.tf` before running commands.

Common providers used:

- AWS provider `5.x`
- Random provider `3.x` (where applicable)

## Local Validation and Testing

Run these commands from each implementation root (or module root where noted):

```bash
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
terraform test -verbose
```

Suggested target directories:

- `s3/codex/unskilled`
- `s3/codex/skilled`
- `s3/claude/unskilled`
- `s3/claude/skilled/modules/s3-bucket`
- `three-tier/codex/unskilled`
- `three-tier/codex/skilled`
- `three-tier/claude/unskilled`
- `three-tier/claude/skilled`

## AWS Credentials Note

Most tests use `mock_provider` and do not require AWS credentials.

One test file performs a real apply:

- `three-tier/claude/unskilled/tests/integration_apply.tftest.hcl`

Run it only when AWS credentials and a test account are available.

## Evaluation Documents

Project-level comparison writeups are available in:

- `s3/claude/README.md`
- `s3/codex/README.md`
- `s3/three-tier/claude/README.md`
- `s3/three-tier/codex/README.md`

Detailed implementation docs also exist under each `skilled/` and `unskilled/` directory.
