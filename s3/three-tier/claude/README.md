# Evaluation: `three-tier/claude/skilled` vs `three-tier/claude/unskilled`

This evaluation compares both implementations using the criteria in `terraform-skill` (`/Users/gwk/.agents/skills/terraform-skill/SKILL.md`), focusing on:
- module hierarchy and structure
- naming and block conventions
- variable quality and validation
- testing strategy
- CI/CD integration
- security/compliance
- version management

## Scope

- Skilled: `/Users/gwk/.codex/worktrees/54b8/test-skills/three-tier/claude/skilled`
- Unskilled: `/Users/gwk/.codex/worktrees/54b8/test-skills/three-tier/claude/unskilled`

## Scorecard (terraform-skill criteria)

| Criterion | Skilled | Unskilled | Assessment |
|---|---|---|---|
| **Module hierarchy (Resource -> Infrastructure -> Composition)** | Root composition + 4 resource modules (`networking`, `alb`, `ecs-fargate`, `rds`) | Flat root module split across files | **Skilled wins** |
| **Standard module structure** (`main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`, `examples/`, `tests/`) | Present in root and each module; has `examples/minimal` and `examples/complete` | Standard root files and tests; only `examples/minimal` | **Skilled wins** |
| **Naming conventions** (`this` for singletons, descriptive names, snake_case) | Consistent (`aws_vpc.this`, `aws_subnet.public/private`) | Also consistent (`this` used widely, descriptive SG names) | **Tie** |
| **Variable quality** (descriptions, types, validation) | Broad validation across root + modules (name, CIDR, port, engine) | Mostly descriptions/types; only one variable `validation` block (`name`) | **Skilled wins** |
| **Cross-input checks** (`check` / `precondition`) | Uses `check` blocks in networking module for subnet/AZ alignment | Uses `terraform_data` preconditions for subnet/AZ alignment and min counts | **Tie** |
| **Count vs for_each guidance** (stable keys preferred) | Uses `for_each` with AZ keys in networking (stable addressing) | Uses `for_each` with index-string keys derived from list position | **Skilled wins** |
| **Testing pyramid / native tests** | 36 `run` blocks, 53 assertions, 7 negative tests (`expect_failures`), per-module + integration tests, mostly mock-provider plan tests | 2 `run` blocks, 7 assertions, no negative tests; one mock plan test + one real apply integration test | **Skilled wins** |
| **CI/CD stages** (validate -> test -> plan; security checks) | Multi-job workflow: fmt, validate per module, tflint, trivy security scan, module tests, integration tests, example plans | Single workflow: fmt/init/validate, mock test, tflint | **Skilled wins** |
| **Security posture** (least privilege, encryption, secret handling, safe destroy) | Strong layered SG model; hardcoded RDS encryption; still stores password in state; inline SG rules; `skip_final_snapshot` defaults true; `deletion_protection` default false | Similar layered SG model; encryption toggle can be disabled; stores password in state; inline SG rules; `skip_final_snapshot` hardcoded true; no deletion protection control | **Skilled slightly ahead** |
| **Version management** (pinning strategy) | Terraform `>=1.7,<2.0`; providers pinned with pessimistic bounds (`~> 5.0`, `~> 3.6`) across root/modules | Terraform `>=1.7,<2.0`; providers use open-ended lower bounds (`>= 5.40.0`, `>= 3.6.0`) | **Skilled wins** |

## Evidence Highlights

### 1. Architecture and reusability

`skilled` follows the skill's module hierarchy guidance directly:
- root composition in `main.tf`
- reusable resource modules under `modules/`
- per-module tests and versions files

`unskilled` is a single module with service-specific files (`networking.tf`, `alb.tf`, `ecs.tf`, `rds.tf`, etc.). It is readable, but less reusable as independent components.

### 2. Validation and input safety

`skilled` validates multiple high-risk inputs early (CIDRs, ports, DB engine, naming rules). This matches the skill's emphasis on fail-fast validation.

`unskilled` has good preconditions for list length/alignment, but lacks most variable-level validation (e.g., no CIDR/port/engine constraints).

### 3. Testing rigor

`skilled` uses Terraform native tests extensively and aligns with the skill's testing strategy:
- module-isolated tests
- mock providers for low-cost validation
- negative tests for invalid inputs
- integration-level wiring tests

`unskilled` testing is minimal in comparison:
- one plan/mock test
- one apply integration test
- no negative or edge-case validation coverage

### 4. CI/CD maturity

`skilled` aligns better with the recommended pipeline progression and includes Trivy scanning. `unskilled` has a clean baseline CI job but omits security scanning and richer staged testing.

### 5. Security/compliance gaps shared by both

Both implementations still have gaps relative to the security guidance in the skill:
- DB credentials are managed/generated in Terraform and therefore end up in state
- security group rules are inline on `aws_security_group` resources rather than separate rule resources
- destructive settings are not production-safe by default (`skip_final_snapshot = true` behavior)

## Final Verdict

Using `terraform-skill` criteria, **`three-tier/claude/skilled` is clearly stronger overall**. It is more modular, better validated, better tested, and better pinned for provider/version stability, with a more complete CI pipeline.

`three-tier/claude/unskilled` remains functional and easier to scan in a single module, but it underperforms on the skill's core engineering rigor signals: reusable module boundaries, depth of validation, and breadth of automated testing/security checks.

## Recommended Next Improvements

1. Add secrets-manager based DB credential flow in both implementations to avoid state-held credentials.
2. Replace inline security-group rules with dedicated rule resources for safer composition.
3. Set safer production defaults (`skip_final_snapshot = false`, `deletion_protection = true`) and allow explicit opt-out for dev.
4. Bring `unskilled` provider constraints to pessimistic pinning (`~>`), and add variable-level validation for CIDRs/ports/engine.
