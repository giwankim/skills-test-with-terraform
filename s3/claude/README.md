# Evaluation: `s3/claude/skilled` vs `s3/claude/unskilled`

This evaluation compares both implementations using criteria from:

- [terraform-skill SKILL.md](https://raw.githubusercontent.com/antonbabenko/terraform-skill/refs/heads/master/SKILL.md)

Evaluation date: February 9, 2026.

## Method

- Reviewed module structure, naming, variables, outputs, tests, CI/CD, and security controls.
- Ran local checks in both directories:
  - `terraform fmt -check -recursive`
  - `terraform init -backend=false`
  - `terraform validate`
  - `terraform test -verbose`

## Scorecard (SKILL.md Criteria)

| Criterion from SKILL.md | `skilled` | `unskilled` | Edge |
|---|---:|---:|---|
| Standard module structure (`main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`, `examples/`, `tests/`) | 5/5 | 4/5 | `skilled` |
| Naming conventions and singleton resource naming (`this`) | 5/5 | 5/5 | Tie |
| Variable/output design and validation rigor | 3/5 | 4/5 | `unskilled` |
| Native test strategy and coverage | 4/5 | 3/5 | `skilled` |
| CI/CD integration (validate, test, lint/security stages) | 5/5 | 4/5 | `skilled` |
| Security defaults and guardrails | 3/5 | 4/5 | `unskilled` |
| Version management strategy | 5/5 | 3/5 | `skilled` |
| Modern Terraform patterns and maintainability | 4/5 | 4/5 | Tie |
| **Overall** | **34/40 (8.5/10)** | **31/40 (7.8/10)** | **`skilled`** |

## Evidence

### 1. Module Structure

- `skilled` follows the recommended module layout with `modules/s3-bucket`, examples (`minimal`, `complete`), tests, and docs.
- `unskilled` is a clean single-module root layout with examples and tests, but less modular for multi-module repos.

Verdict: `skilled` is closer to the SKILL.md module architecture pattern.

### 2. Naming and Code Structure Standards

- Both use singleton `this` resource names consistently.
- Both keep generally clean resource and variable block layouts.

Verdict: Tie.

### 3. Variables, Outputs, and Validation

- `skilled` has a larger feature surface (logging, lifecycle transitions, bucket key toggle) but limited validation beyond `sse_algorithm`.
- `unskilled` has stronger guardrails:
  - Regex and length validation on `name_prefix`
  - Cross-variable `check` requiring `kms_key_arn` when `sse_algorithm = "aws:kms"`
  - Consistent default tags via `locals`

Verdict: `unskilled` is stronger on validation and governance.

### 4. Testing Strategy

- `skilled`: 12 test runs, includes positive + negative-path coverage (`expect_failures`), and `plan`/`apply` mix.
- `unskilled`: 5 test runs, good coverage of defaults and encryption/versioning, but narrower scenario coverage.

Important quality signal:

- `skilled` test execution surfaces provider warnings around lifecycle rule filter/prefix combinations, showing a real compatibility issue in lifecycle rule generation.

Verdict: `skilled` has broader coverage, but `unskilled` has cleaner semantics in some assertions.

### 5. CI/CD and Security Scanning

- `skilled` workflow includes validate, tests, TFLint, and Trivy config scanning stages.
- `unskilled` workflow includes fmt/init/validate/test/TFLint, but no Trivy/Checkov-style security scan.

Verdict: `skilled` is more aligned with SKILL.md CI/security recommendations.

### 6. Security Posture

- Both default to encryption, versioning enabled, and public access blocks.
- `skilled` allows turning off public access block (`block_public_access = false`), which increases risk surface.
- `unskilled` always enforces public access blocks and includes KMS configuration checks.

Verdict: `unskilled` is safer by default.

### 7. Version Strategy

- `skilled` uses SKILL.md-aligned pessimistic constraints:
  - `required_version = "~> 1.9"`
  - AWS provider `~> 5.0`
- `unskilled` uses wider Terraform bounds (`>= 1.7.0, < 2.0.0`), which is more permissive but less controlled.

Verdict: `skilled` aligns better with the recommended version strategy.

## Validation Results

- Both implementations passed:
  - `terraform fmt -check -recursive`
  - `terraform validate`
  - `terraform test -verbose`
- During `skilled` tests, Terraform emitted lifecycle warnings that indicate future provider incompatibility risk when no lifecycle filter/prefix is set.

## Final Verdict

`s3/claude/skilled` is overall more aligned with the terraform-skill rubric due to stronger structure, broader test coverage, and more complete CI/security automation.

`s3/claude/unskilled` is still solid and wins on defensive validation and safer defaults, but has narrower testing scope and less CI security depth.

Most important follow-up for `skilled`: fix lifecycle rule filter generation and tighten security/validation guardrails.
