# Best Practices Comparison: `with/` vs `without/`

This document evaluates two Terraform three-tier stacks against best practices from three authoritative sources:
- [HashiCorp Terraform Recommended Practices](https://developer.hashicorp.com/terraform/cloud-docs/recommended-practices)
- [AWS Prescriptive Guidance for Terraform](https://docs.aws.amazon.com/prescriptive-guidance/latest/terraform-aws-provider-best-practices/introduction.html)
- [Google Cloud Terraform Best Practices: Style & Structure](https://docs.cloud.google.com/docs/terraform/best-practices/general-style-structure)

---

## 1. Module Structure & Organization

| Best Practice | Source | `with/` | `without/` |
|---|---|---|---|
| Use standard module structure (main.tf, variables.tf, outputs.tf, versions.tf) | All three | **PASS** - every module has the canonical four files | **PASS** - root module has all standard files |
| Group related resources by purpose in logically named files | Google, AWS | **PASS** - each module is a logical grouping (networking, alb, ecs-fargate, rds) | **PASS** - files named by purpose (networking.tf, security.tf, alb.tf, ecs.tf, iam.tf, rds.tf) |
| Don't wrap single resources in modules | AWS | **PASS** - each module contains 3-11 related resources | N/A (no sub-modules) |
| Provide `examples/` with subdirectories | All three | **PASS** - `examples/minimal/` and `examples/complete/` | **PARTIAL** - only `examples/minimal/`; no "complete" example |
| Include README.md | All three | **PASS** | **PASS** |
| Keep module inheritance flat (1-2 levels) | AWS | **PASS** - single level of nesting (root -> modules/) | **PASS** - flat, no nesting |
| Use `locals.tf` for reused expressions | AWS, Google | **PASS** - locals in each module's main.tf | **PASS** - dedicated `locals.tf` file |
| Separate locals into `locals.tf` | AWS | **PARTIAL** - locals are embedded in main.tf within modules rather than in a separate file | **PASS** - dedicated `locals.tf` |

### Verdict
Both stacks follow the standard module structure well. `with/` uses sub-modules for clearer separation of concerns; `without/` uses file-per-service in a flat layout. Both are valid approaches per the guides. `without/` is missing a "complete" example.

---

## 2. Naming Conventions

| Best Practice | Source | `with/` | `without/` |
|---|---|---|---|
| Use `this` or `main` for single resources of a type | Google, AWS | **PASS** - consistently uses `"this"` | **PASS** - consistently uses `"this"` |
| Don't repeat resource type in resource name | Google | **PASS** | **PASS** |
| Use `snake_case` for resource names | HashiCorp Style | **PASS** | **PASS** |
| Use descriptive, meaningful names for differentiating resources | Google | **PASS** - `aws_subnet.public`, `aws_subnet.private` | **PASS** - same pattern |
| Handle AWS name length limits | AWS | **PASS** - `substr()` for ALB (32 char), target group | **PASS** - `substr()` for ALB (32 char), RDS identifier (54 char) |

### Verdict
Both stacks follow naming conventions well. Identical patterns.

---

## 3. Variable Definitions

| Best Practice | Source | `with/` | `without/` |
|---|---|---|---|
| All variables in `variables.tf` | All three | **PASS** | **PASS** |
| Include descriptions for all variables | All three | **PASS** - all 27 variables have descriptions | **PASS** - all 24 variables have descriptions |
| Explicit types for all variables | Google, AWS | **PASS** | **PASS** |
| Defaults for environment-independent values | Google, AWS | **PASS** | **PASS** |
| No defaults for environment-specific values | Google, AWS | **PASS** - `name_prefix`, `availability_zones`, `public_subnet_cidrs`, `private_subnet_cidrs` have no defaults | **PARTIAL** - `availability_zones`, `public_subnet_cidrs`, `private_subnet_cidrs` have hardcoded defaults (`us-east-1a/b`, `10.0.x.x/24`), which bakes in a specific region |
| Name numeric variables with units | Google | **PASS** - `ecs_container_memory` described as "MiB", `rds_allocated_storage` described as "GiB" | **PASS** - `task_memory` described as "MiB", `db_allocated_storage` described as "GiB" |
| Use positive boolean names (`enable_x` not `disable_x`) | Google, AWS | **PASS** - `create_nat_gateway` | **PASS** - `create_nat_gateway_per_az`, `enable_circuit_breaker`, `db_storage_encrypted` |
| Input validation blocks | HashiCorp | **PASS** - extensive validation on name_prefix, CIDRs, ports, engine | **PARTIAL** - validation only on `name` regex; no CIDR, port, or engine validation |
| Only parameterize values with concrete use cases | Google | **PASS** | **PASS** - exposes a few more knobs (deregistration_delay, health_check_interval, db_apply_immediately) |
| Mark sensitive variables | AWS | **PASS** - `rds_password` is `sensitive = true` | **PASS** - `db_password` is `sensitive = true` |

### Verdict
`with/` is stronger on input validation (8+ validation blocks across root + module variables vs 1 in `without/`). `without/` hardcodes default AZs and subnet CIDRs to a specific region, which is poor practice per Google and AWS guides (environment-specific values should not have defaults).

---

## 4. Outputs

| Best Practice | Source | `with/` | `without/` |
|---|---|---|---|
| All outputs in `outputs.tf` | All three | **PASS** | **PASS** |
| Meaningful descriptions for all outputs | Google | **PASS** - full sentence descriptions | **PARTIAL** - terse descriptions (e.g., "VPC ID.", "ALB ARN.") |
| Reference resource attributes (not input pass-through) | Google | **PASS** | **PASS** |
| Export useful values root modules might need | Google | **PASS** - 14 outputs covering all tiers + security groups | **PASS** - 11 outputs; missing `ecs_cluster_name`, `rds_db_name` |

### Verdict
`with/` has more descriptive output descriptions and exports a few more useful values. Both follow the structural conventions.

---

## 5. Provider & Version Constraints

| Best Practice | Source | `with/` | `without/` |
|---|---|---|---|
| Pin required_version | All three | **PASS** - `>= 1.7.0, < 2.0.0` | **PASS** - `>= 1.7.0, < 2.0.0` |
| Pin provider versions with upper bound | AWS | **PASS** - `~> 5.0` (pessimistic, allows 5.x only) | **FAIL** - `>= 5.40.0` (no upper bound; could pull 6.x+ with breaking changes) |
| Declare required_providers in modules | AWS | **PASS** - each sub-module has its own `versions.tf` | N/A (no sub-modules) |
| Don't configure providers in modules | AWS | **PASS** - modules inherit provider from root | N/A |

### Verdict
`with/` uses pessimistic version constraints (`~> 5.0`) which prevent accidental major version upgrades. `without/` uses open-ended `>= 5.40.0` which could pull a future 6.x release with breaking changes -- this violates AWS best practices for version pinning.

---

## 6. Security

| Best Practice | Source | `with/` | `without/` |
|---|---|---|---|
| Least-privilege security groups | AWS | **PASS** - layered: ALB <- ECS <- RDS, each restricted by source SG | **PASS** - identical pattern |
| RDS not publicly accessible | AWS | **PASS** - private subnets, `publicly_accessible` not set (defaults false) | **PASS** - `publicly_accessible = false` explicit |
| Storage encryption enabled | AWS | **PASS** - `storage_encrypted = true` hardcoded | **PASS** - `storage_encrypted = var.db_storage_encrypted` (default true, but configurable to false) |
| Secrets management (don't store in state) | AWS | **PARTIAL** - password in state via `random_password`; `sensitive = true` on var | **PARTIAL** - same approach |
| Use IAM roles, not users | AWS | **PASS** - ECS task execution role + task role | **PASS** - same |
| Least-privilege IAM | AWS | **PASS** - only `AmazonECSTaskExecutionRolePolicy` attached; task role empty | **PASS** - identical |
| Use separate security group rules (attachment resources) instead of embedded inline rules | AWS | **FAIL** - uses inline `ingress`/`egress` blocks (embedded, not attachment) | **FAIL** - same inline pattern |
| Deletion protection for stateful resources | Google | **FAIL** - no `prevent_destroy` lifecycle on RDS | **FAIL** - no `prevent_destroy` lifecycle on RDS |
| `skip_final_snapshot = true` dangerous for production | AWS | **PARTIAL** - defaults to `true` (dev-friendly; production risk) | **PARTIAL** - hardcoded to `true` (no variable to override) |

**Note on inline vs attachment security group rules:** Both stacks use embedded `ingress`/`egress` blocks inside `aws_security_group` resources. AWS Prescriptive Guidance recommends using separate `aws_security_group_rule` or `aws_vpc_security_group_ingress_rule`/`aws_vpc_security_group_egress_rule` attachment resources instead. This avoids conflicts when rules are managed from multiple sources.

### Verdict
Security posture is similar. Both lack `prevent_destroy` on stateful resources (RDS), and both use inline security group rules instead of the recommended attachment resources. `without/` allows encryption to be disabled via variable, which is a risk. `with/` hardcodes encryption on, which is safer. Both store the database password in state via `random_password`, which the AWS guide warns against (recommending AWS Secrets Manager instead).

---

## 7. Testing

| Best Practice | Source | `with/` | `without/` |
|---|---|---|---|
| Write tests for modules | HashiCorp | **PASS** - 5 test files, ~36 assertions | **PASS** - 2 test files, 7 assertions |
| Test with mock providers | HashiCorp | **PASS** - all unit tests use mock providers | **PASS** - plan_mock.tftest.hcl uses mocks |
| Test individual modules | HashiCorp | **PASS** - per-module test files (networking, alb, ecs, rds) | **FAIL** - only root-level tests; no per-component test isolation |
| Integration tests | HashiCorp | **PASS** - separate integration test at root level | **PASS** - integration_apply.tftest.hcl against examples/minimal |
| Validate edge cases and invalid input | HashiCorp | **PASS** - tests for invalid engine, invalid port, invalid name_prefix, invalid CIDR, insufficient AZs | **FAIL** - no negative/validation tests |
| Test tag propagation | HashiCorp | **PASS** - tag propagation tests in every module | **FAIL** - no tag tests |
| Test security group configuration | HashiCorp | **PASS** - explicit SG ingress assertions | **FAIL** - no SG assertions |

### Verdict
`with/` has dramatically more comprehensive testing. It tests each module in isolation with ~9 tests per module including positive, negative, edge case, and security assertions. `without/` has only 7 assertions across 2 test files with no negative testing, no per-component isolation, and no security or tag coverage.

---

## 8. Code Style & Formatting

| Best Practice | Source | `with/` | `without/` |
|---|---|---|---|
| Conform to `terraform fmt` | All three | **PASS** | **PASS** |
| Consistent 2-space indentation | HashiCorp Style | **PASS** | **PASS** |
| Descriptive comments where needed | Google | **PASS** - test sections commented | **PASS** - section headers in variables.tf (`# --- VPC ---`) |
| Limit ternary complexity (one per line) | Google | **PASS** | **PASS** |
| Use locals to simplify complex expressions | Google, AWS | **PASS** - `name_prefix`, `common_tags`, subnet maps | **PASS** - `common_tags`, subnet maps, `effective_db_password`, `nat_gateway_subnet_keys` |

### Verdict
Both stacks follow consistent formatting and style conventions. `without/` uses section header comments in variables.tf which aids readability. Both use locals appropriately.

---

## 9. Tagging Strategy

| Best Practice | Source | `with/` | `without/` |
|---|---|---|---|
| Consistent tagging across all resources | AWS | **PASS** - `common_tags` with `ManagedBy`, `Project` merged everywhere | **PASS** - `common_tags` with `ManagedBy`, `Module`, `Name` merged everywhere |
| `Name` tag on all resources | AWS | **PASS** | **PASS** |
| `ManagedBy` tag | AWS | **PASS** - `"terraform"` | **PASS** - `"terraform"` |
| User-extensible tags | AWS | **PASS** - `var.tags` merged in | **PASS** - `var.tags` merged in |
| Use `default_tags` in provider | AWS | **FAIL** - uses merge pattern at resource level | **FAIL** - uses merge pattern at resource level |

**Note:** AWS recommends using `provider "aws" { default_tags { ... } }` instead of merging tags at every resource. Neither stack uses this approach. Using `default_tags` is cleaner but only works at the root module level (not inside reusable modules that don't configure providers), so the merge pattern is a reasonable alternative for modules.

### Verdict
Both follow the same tagging pattern. Neither uses `default_tags`, but that's acceptable for reusable modules since modules should not configure providers.

---

## 10. Modularity & Reusability

| Best Practice | Source | `with/` | `without/` |
|---|---|---|---|
| Encapsulate logical relationships | AWS, HashiCorp | **PASS** - 4 modules (networking, alb, ecs-fargate, rds) | **PARTIAL** - flat structure; no sub-modules |
| Modules don't configure providers | AWS | **PASS** | N/A |
| Export at least one output per resource | AWS | **PASS** - each module exports key resource attributes | N/A (not a module of modules) |
| Separate reusable modules from root config | HashiCorp | **PASS** - clear separation in `modules/` | **FAIL** - everything is in root; not reusable as individual components |
| Minimal + complete examples | HashiCorp | **PASS** - both provided | **PARTIAL** - only minimal |

### Verdict
`with/` is designed for reusability -- each sub-module can be used independently. `without/` is a monolithic root module; you must take the entire stack or nothing. Both approaches are valid for different use cases, but the modular approach better follows HashiCorp and AWS guidance for teams and long-term maintainability.

---

## 11. Input Validation & Preconditions

| Best Practice | Source | `with/` | `without/` |
|---|---|---|---|
| Variable-level `validation` blocks | HashiCorp | **PASS** - name_prefix (regex+length), CIDRs, ports (1-65535), engine (enum) | **PARTIAL** - only `name` regex |
| Cross-variable `check` or `precondition` blocks | HashiCorp | **PASS** - `check` blocks in networking module (subnet count == AZ count) | **PASS** - `precondition` blocks on `terraform_data` resource (subnet/AZ count alignment, minimum 2) |

### Verdict
`with/` has far more comprehensive input validation. Invalid CIDRs, out-of-range ports, and unsupported database engines are caught at plan time in `with/`. In `without/`, these errors would only surface during apply (or not at all).

---

## Summary Scorecard

| Category | `with/` | `without/` |
|---|---|---|
| Module Structure | Strong | Good |
| Naming Conventions | Strong | Strong |
| Variable Definitions | Strong | Moderate (missing validation, region-specific defaults) |
| Outputs | Strong | Good (terse descriptions, fewer exports) |
| Version Constraints | Strong | Weak (no upper bound on AWS provider) |
| Security | Good | Good (but encryption is configurable off) |
| Testing | Excellent (36+ assertions, per-module) | Minimal (7 assertions, root-only) |
| Code Style | Strong | Strong |
| Tagging | Good | Good |
| Modularity | Excellent | Flat/monolithic |
| Input Validation | Excellent | Minimal |

### Key Differentiators

**`with/` strengths:**
- Sub-module architecture enables independent reuse and testing
- Comprehensive variable validation catches errors early
- 36+ test assertions with per-module isolation, negative tests, and edge cases
- Pessimistic provider version pinning prevents surprise breaking changes
- Two examples (minimal + complete) showing different usage patterns
- Encryption hardcoded on (cannot be disabled)

**`without/` strengths:**
- Simpler, flatter structure easier to understand at a glance
- Section header comments in variables.tf for readability
- More operational knobs exposed (deregistration_delay, health_check_interval, health_check_grace_period, circuit_breaker toggle, log_retention_days, db_apply_immediately)
- NAT-gateway-per-AZ option for HA
- Explicit `publicly_accessible = false` on RDS (defense in depth)

**`without/` weaknesses vs best practices:**
- No upper bound on AWS provider version (supply chain risk)
- Hardcoded region-specific defaults (us-east-1a/b) on required variables
- Only 1 validation block (vs 8+ in `with/`)
- Only 7 test assertions (vs 36+ in `with/`), no per-component isolation, no negative tests
- No "complete" example
- Monolithic -- cannot reuse individual components

**Shared weaknesses (both stacks):**
- Neither uses `aws_vpc_security_group_ingress_rule`/`aws_vpc_security_group_egress_rule` attachment resources (AWS recommendation)
- Neither uses `prevent_destroy` lifecycle on RDS
- Both store generated passwords in Terraform state rather than using AWS Secrets Manager
- Neither uses `default_tags` (acceptable for reusable modules)
- `skip_final_snapshot` defaults to true in both (production risk)

### Sources
- [HashiCorp Terraform Recommended Practices](https://developer.hashicorp.com/terraform/cloud-docs/recommended-practices)
- [HashiCorp Standard Module Structure](https://developer.hashicorp.com/terraform/language/modules/develop/structure)
- [HashiCorp Terraform Style Guide](https://developer.hashicorp.com/terraform/language/style)
- [AWS Prescriptive Guidance: Terraform Best Practices - Introduction](https://docs.aws.amazon.com/prescriptive-guidance/latest/terraform-aws-provider-best-practices/introduction.html)
- [AWS Prescriptive Guidance: Code Structure](https://docs.aws.amazon.com/prescriptive-guidance/latest/terraform-aws-provider-best-practices/structure.html)
- [AWS Prescriptive Guidance: Security](https://docs.aws.amazon.com/prescriptive-guidance/latest/terraform-aws-provider-best-practices/security.html)
- [AWS Prescriptive Guidance: Version Management](https://docs.aws.amazon.com/prescriptive-guidance/latest/terraform-aws-provider-best-practices/version.html)
- [Google Cloud Terraform Best Practices: General Style & Structure](https://docs.cloud.google.com/docs/terraform/best-practices/general-style-structure)
