# Terraform Stack Comparison: `with/` vs `without/`

Both stacks implement the same three-tier AWS application architecture: **ALB -> ECS Fargate -> RDS + S3**, deployed across multiple availability zones with public/private subnet separation. The core infrastructure is identical; the differences are in style, defaults, validation, and operational flexibility.

## File Organization

**`with/`** uses 4 `.tf` files with a monolithic layout:
- `main.tf` (561 lines -- all resources, locals, check blocks, data sources)
- `variables.tf`, `outputs.tf`, `versions.tf`

**`without/`** uses 12 `.tf` files split by resource domain:
- `networking.tf`, `alb.tf`, `ecs.tf`, `iam.tf`, `rds.tf`, `s3.tf`, `security.tf`, `locals.tf`
- `main.tf` (only `terraform_data` validation resource)
- `variables.tf`, `outputs.tf`, `versions.tf`

The `without/` approach groups resources by logical domain, making individual components easier to locate. The `with/` approach keeps everything in one file, which is easier to scan top-to-bottom but harder to navigate at scale.

## Variable Naming and Defaults

`with/` defines **43 variables**; `without/` defines **40**.

| Aspect | `with/` | `without/` |
|---|---|---|
| Name variable | `name_prefix` (required) | `name` (required) |
| VPC CIDR default | `10.42.0.0/16` | `10.0.0.0/16` |
| Availability zones | Required, no default | Default: `["us-east-1a", "us-east-1b"]` |
| Subnet CIDRs | Required, no defaults | Defaults provided |
| Naming convention | Service-prefixed (`ecs_container_cpu`, `rds_port`, `alb_listener_port`) | Shorter/mixed (`task_cpu`, `db_port`, `health_check_path`) |
| Log retention default | 14 days | 7 days |
| RDS engine version | `null` (AWS picks) | `"15.5"` (pinned) |
| RDS password generation | length 20, no special chars | length 24, special chars with custom set |
| RDS identifier | `name` (fixed, deterministic) | `name_prefix` (AWS appends random suffix) |

**Variables unique to `with/`**: `ecs_container_name`, `ecs_container_environment` (map for custom env vars), `ecs_wait_for_steady_state`, `s3_bucket_name` (override), `rds_deletion_protection`.

**Variables unique to `without/`**: `alb_ingress_cidr_blocks`, `alb_listener_protocol`, `target_group_deregistration_delay`, `assign_public_ip`, `create_nat_gateway_per_az`.

## NAT Gateway Strategy

**`with/`** has a boolean `create_nat_gateway` (default `true`) that toggles between 0 or 1 NAT gateways. Setting it to `false` skips NAT entirely, useful for dev/test cost savings. Uses `count`.

**`without/`** always creates at least one NAT gateway. A boolean `create_nat_gateway_per_az` (default `false`) optionally creates one per AZ for high availability. Uses `for_each`. Cannot skip NAT entirely.

## Input Validation

**`with/`** uses two validation mechanisms:
1. **Inline `validation {}` blocks** on many variables: port ranges (1-65535), CIDR format (`can(cidrnetmask(...))`), protocol values, RDS engine allowlist, `name_prefix` format (lowercase alphanumeric + hyphens, max 20 chars), and AZ count.
2. **Top-level `check {}` blocks** in `main.tf` to verify subnet counts match AZ count.

**`without/`** uses:
1. **One inline `validation {}` block** on `name` only (alphanumeric + hyphens, allows uppercase).
2. **`terraform_data` resource with `precondition` blocks** to verify at least 2 of each (AZs, public subnets, private subnets) and that counts match.

`without/` lacks port range validation, CIDR format validation, protocol validation, engine validation, and name length checks.

## IAM Differences

**S3 permissions in the ECS task role**:
- `with/` grants 3 actions: `s3:GetObject`, `s3:ListBucket`, `s3:PutObject`
- `without/` grants 4 actions: adds `s3:DeleteObject`

**Role naming**: `with/` uses fixed `name` (deterministic); `without/` uses `name_prefix` (AWS appends random suffix for uniqueness).

**Policy definitions**: `with/` inlines `jsonencode({...})` directly in resources; `without/` defines policies as `locals` and references them, sharing the assume-role policy between both roles.

## S3 Encryption

**`with/`** creates an explicit `aws_s3_bucket_server_side_encryption_configuration` resource with `AES256`.

**`without/`** has no encryption configuration resource, relying on the AWS default (SSE-S3/AES256 since January 2023).

The result is identical encryption. `with/` makes it explicit and visible in Terraform state.

**Bucket name generation**:
- `with/`: `random_string` (10 chars, lowercase alphanumeric), with an optional `s3_bucket_name` override variable
- `without/`: `random_id` (4 bytes = 8 hex chars), with name sanitization, no override

## Output Differences

`with/` exposes **20 outputs**; `without/` exposes **17**. They share 13 outputs in common.

**Unique to `with/`** (7): `alb_security_group_id`, `ecs_cluster_name`, `ecs_task_definition_arn`, `rds_address`, `rds_arn`, `rds_db_name`, and a composite `ecs_to_rds_connectivity` object (endpoint, port, security group IDs, subnet group name).

**Unique to `without/`** (4): `ecs_security_group_id`, `rds_endpoint`, `db_name`, `db_username`. Notably, `without/` exposes `db_username` as a plain output.

## Minor Differences

| Aspect | `with/` | `without/` |
|---|---|---|
| ECS env vars | Configurable via `ecs_container_environment` map; base vars merged with user-supplied extras; omits `DB_USER` | Hardcoded list including `DB_USER`; no custom env var support |
| Container name | Configurable (`ecs_container_name`, default `"app"`) | Hardcoded `"app"` |
| ALB ingress CIDRs | Hardcoded `0.0.0.0/0` | Configurable via variable |
| ALB listener protocol | Hardcoded `HTTP` | Configurable via variable |
| ECS `assign_public_ip` | Hardcoded `false` | Configurable via variable |
| Target group dereg delay | Not set (AWS default: 300s) | Configurable (default: 30s) |
| RDS storage type | Explicit `gp3` | Not set (AWS default, typically `gp2`) |
| Common tags | `ManagedBy`, `Project` | `ManagedBy`, `Module`, `Name` |
| Provider constraints | `aws ~> 5.0`, `random ~> 3.6` | `aws >= 5.40.0`, `random >= 3.6.0` |
| Subnet map keys | AZ names (`"us-east-1a"`) | Numeric indices (`"0"`, `"1"`) |

## Summary

**`with/`** favors explicit configuration: more validation, explicit encryption, a composite connectivity output, deterministic resource naming, and configurable container environment -- at the cost of a monolithic file layout and some hardcoded operational settings (ALB ingress, public IP).

**`without/`** favors modular organization and operational flexibility: split files by domain, configurable ALB ingress/protocol/deregistration, per-AZ NAT gateway option, and `name_prefix`-based naming for safe multi-instance deployment -- but with less input validation and implicit reliance on AWS defaults for encryption and storage type.

Neither stack is strictly better. `with/` catches more input errors early and is more self-documenting. `without/` is easier to navigate and offers more runtime knobs. The ideal stack would combine `without/`'s file organization with `with/`'s validation depth.
