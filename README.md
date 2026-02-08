# Terraform Test Skills

A side-by-side comparison of Terraform infrastructure built **with** vs **without** Claude Code agent skills. Each stack is implemented twice -- once with the [terraform-skill](https://github.com/anthropics/agent-skills/tree/main/terraform-skill) loaded, and once with vanilla Claude Code -- then evaluated against best practices from HashiCorp, AWS, and Google Cloud.

## Repository Structure

```
.
├── simple/
│   ├── with/          # S3 module built with agent skills
│   │   └── modules/s3-bucket/
│   ├── without/       # S3 module built without skills
│   └── README.md      # Detailed comparison
│
├── three-tier/
│   ├── with/          # VPC + ALB + ECS Fargate + RDS, built with agent skills
│   │   └── modules/{networking,alb,ecs-fargate,rds}/
│   ├── without/       # Same stack, built without skills
│   └── README.md      # Detailed comparison
│
└── README.md          # This file
```

## Stacks

### Simple: Reusable S3 Bucket Module

A reusable S3 bucket module with encryption, versioning, lifecycle management, and public access blocking. Both implementations share secure-by-default posture and the `"this"` resource naming convention.

- **`with/`** -- nested under `modules/s3-bucket/`; 12 test runs, flexible lifecycle rules, access logging support
- **`without/`** -- root-level module; 5 test runs, CI pipeline, tflint, input validation with `check` blocks

### Three-Tier: Production-Style AWS Stack

A VPC + ALB + ECS Fargate + RDS architecture. Both implementations use layered security groups, private subnets for compute/data tiers, and consistent tagging.

- **`with/`** -- 4 sub-modules with per-module tests (~36 assertions), extensive input validation, Trivy security scanning, pessimistic provider pinning (`~> 5.0`)
- **`without/`** -- flat single-module layout; 7 assertions across 2 test files, tflint, more operational knobs exposed (deregistration delay, health check tuning, circuit breaker toggle)

## Key Differences

| Aspect | `with/` (skills) | `without/` (no skills) |
|---|---|---|
| **Architecture** | Sub-module per component (`modules/`) | Flat, file-per-service |
| **Input validation** | Extensive (`validation` blocks on names, CIDRs, ports, engines) | Minimal (regex on name only in three-tier) |
| **Test coverage** | 12 runs (simple), ~36 assertions (three-tier); includes negative tests | 5 runs (simple), 7 assertions (three-tier); no negative tests |
| **CI/CD** | Validate + security scan + test + plan-examples | fmt + init + validate + test + tflint |
| **Security scanning** | Trivy (HIGH/CRITICAL) | None |
| **Linting** | tflint in CI | tflint in CI + `.tflint.hcl` config committed |
| **Provider pinning** | `~> 5.0` (pessimistic, prevents major bumps) | `>= 5.40.0` in three-tier (no upper bound) |
| **Modularity** | Reusable sub-modules with independent tests | Monolithic root modules |
| **Examples** | `minimal/` + `complete/` | `minimal/` only (three-tier) |

## Findings

Both approaches produce functional, secure-by-default infrastructure. The differences are in engineering rigor:

- **Skills-assisted (`with/`)** consistently produced more modular code, more comprehensive tests (including negative/edge-case testing), and better input validation. The sub-module architecture enables independent reuse and testing.
- **Unassisted (`without/`)** produced simpler, flatter structures that are easier to read at a glance. It included some things the skills version missed (committed `.tflint.hcl` configs, `check`/`precondition` blocks in the simple stack). However, it had significantly less test coverage and weaker version constraints.
- **Neither was perfect.** Both stacks share weaknesses: inline security group rules (vs attachment resources), no `prevent_destroy` on RDS, passwords in Terraform state, `skip_final_snapshot = true`.

See `simple/README.md` and `three-tier/README.md` for full per-stack comparisons with detailed scorecards.

## Prerequisites

- Terraform >= 1.7.0
- AWS provider ~> 5.0

## Usage

Tests use mock providers and run without AWS credentials:

```sh
# Simple stack (with skills)
cd simple/with/modules/s3-bucket
terraform init
terraform test

# Simple stack (without skills)
cd simple/without
terraform init
terraform test

# Three-tier stack (with skills) -- per-module
cd three-tier/with/modules/networking
terraform init && terraform test

# Three-tier stack (without skills)
cd three-tier/without
terraform init
terraform test
```
