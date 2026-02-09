# Evaluation: `three-tier/codex/skilled` vs `three-tier/codex/unskilled`

This comparison uses criteria from the Terraform agentic skill document:

- [`terraform-skill` `SKILL.md`](https://raw.githubusercontent.com/antonbabenko/terraform-skill/refs/heads/master/SKILL.md)

## Method

- Performed file-level comparison between both implementations.
- Ran local root checks in each directory:
  - `terraform fmt -check -recursive` (pass in both)
  - `terraform init -backend=false && terraform validate && terraform test -verbose` (pass in both)
- Attempted module-by-module reruns; those were blocked by offline provider resolution to `registry.terraform.io`, so module test comparison is based on static review of test files.

## Score Summary

| Implementation | Score (/10) | Result |
|---|---:|---|
| `skilled` | **8.8** | Better alignment to skill guidance |
| `unskilled` | **7.9** | Good baseline, weaker on modern/security posture |

## Criteria Evaluation (From `SKILL.md`)

| Skill criterion | `skilled` | `unskilled` | Better |
|---|---|---|---|
| Code structure philosophy (modular hierarchy, examples, standard files) | Pass | Pass | Tie |
| Naming conventions (`this`, descriptive resources, file conventions) | Pass | Pass | Tie |
| Resource/variable structure quality | Pass | Pass | Tie |
| Dependency management (prefer implicit graph/locals over explicit `depends_on`) | Pass | Partial | `skilled` |
| Testing strategy (native tests + mock providers, module + integration coverage) | Pass | Pass | Tie |
| CI/CD stages (validate, test, security scan, plan) | Pass | Pass | Tie |
| Security defaults for stateful resources | Strong pass | Partial | `skilled` |
| Version/feature management alignment | Strong pass | Partial | `skilled` |
| Documentation accuracy vs implementation | Partial | Pass | `unskilled` |

## Key Findings

1. `skilled` improves dependency hygiene by removing a synthetic listener dependency path:
   - Removed `listener_arn` wiring at root and module interface (`three-tier/codex/skilled/main.tf`, `three-tier/codex/skilled/modules/ecs-fargate/variables.tf`)
   - Removed explicit `depends_on = [var.listener_arn]` (`three-tier/codex/skilled/modules/ecs-fargate/main.tf`)
   - `unskilled` still carries this explicit dependency (`three-tier/codex/unskilled/modules/ecs-fargate/main.tf`)

2. `skilled` adopts modern Terraform 1.11 write-only arguments for DB password handling:
   - Uses `password_wo` and `password_wo_version` in RDS (`three-tier/codex/skilled/modules/rds/main.tf`)
   - Adds corresponding input version marker (`three-tier/codex/skilled/modules/rds/variables.tf`)
   - Raises required Terraform versions where needed (`three-tier/codex/skilled/versions.tf`, `three-tier/codex/skilled/modules/rds/versions.tf`)

3. `skilled` has safer RDS operational defaults (security/compliance criterion):
   - `apply_immediately = false`, `skip_final_snapshot = false`, `deletion_protection = true`
   - `unskilled` uses the opposite defaults (`true`, `true`, `false`)
   - Evidence: `three-tier/codex/skilled/modules/rds/variables.tf` vs `three-tier/codex/unskilled/modules/rds/variables.tf`

4. CI remains strong in both, but `skilled` aligns workflow Terraform with its 1.11 feature set:
   - `skilled` workflow pins `~1.11`
   - `unskilled` workflow uses `~1.9`
   - Evidence: `three-tier/codex/skilled/.github/workflows/terraform.yml`, `three-tier/codex/unskilled/.github/workflows/terraform.yml`

5. Documentation quality regresses in `skilled` (important downside):
   - `rds_skip_final_snapshot` documented as `true` but code default is `false`
   - Terraform requirement documented as `>= 1.7.0` while root requires `>= 1.11.0`
   - Complete example no longer matches README claim of custom container port `8080` (example is `80`)
   - Evidence: `three-tier/codex/skilled/README.md`, `three-tier/codex/skilled/variables.tf`, `three-tier/codex/skilled/versions.tf`, `three-tier/codex/skilled/examples/complete/main.tf`

## Shared Gaps Against Skill Guidance

- Both implementations still use inline SG rules instead of dedicated SG rule resources.
- Both still generate DB secrets with `random_password`, so secret material still exists in Terraform state.
- Both use ranged Terraform constraints (`>= x, < 2.0.0`) rather than a strict pinned minor strategy recommended in the skill’s versioning section.

## Verdict

`three-tier/codex/skilled` is the stronger implementation under the `terraform-skill` rubric due to better dependency modeling, modern Terraform feature adoption, and materially safer RDS defaults. `three-tier/codex/unskilled` remains competitive on structure/testing, and currently has more reliable docs consistency.
