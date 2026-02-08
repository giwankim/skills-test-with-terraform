# Three-Tier AWS Architecture

A modular Terraform stack that deploys a production-ready three-tier architecture on AWS: VPC networking, an internet-facing ALB, ECS Fargate services, and an RDS database.

## Architecture

The stack is composed of four modules wired together in a clear dependency chain:

```
Internet
   │
   ▼
┌──────────────────────────────────────────────┐
│  module.networking                           │
│  VPC · Public Subnets · Private Subnets      │
│  Internet GW · NAT GW (optional)             │
└──────┬──────────────────────┬────────────────┘
       │ public subnets       │ private subnets
       ▼                      ▼
┌──────────────┐    ┌──────────────────────────┐
│  module.alb  │    │  module.ecs_fargate      │
│  ALB · TG ·  │───▶│  Cluster · Service ·     │
│  Listener    │    │  Task Def · IAM · SG     │
└──────────────┘    └────────────┬─────────────┘
                                 │ ecs sg
                                 ▼
                    ┌──────────────────────────┐
                    │  module.rds              │
                    │  DB Instance · Subnet    │
                    │  Group · SG · Password   │
                    └──────────────────────────┘
```

Database connection details (`DB_HOST`, `DB_NAME`, `DB_PORT`) are automatically injected into the ECS container environment.

## Usage

### Minimal

```hcl
provider "aws" {
  region = "us-east-1"
}

module "three_tier" {
  source = "../../"

  name_prefix          = "minimal"
  availability_zones   = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs  = ["10.42.0.0/24", "10.42.1.0/24"]
  private_subnet_cidrs = ["10.42.10.0/24", "10.42.11.0/24"]

  tags = {
    Environment = "dev"
    Example     = "minimal"
  }
}
```

### Complete

See [`examples/complete/`](examples/complete/) for a full example with three AZs, custom container settings, Multi-AZ RDS, and a custom health check path.

Key customizations shown in the complete example:

- Three availability zones with separate subnets
- Custom container port (`8080`), CPU (`512`), and memory (`1024`)
- Multiple ECS tasks (`desired_count = 2`)
- Multi-AZ RDS with larger storage (`50 GiB`)
- Application environment variables injected via `ecs_container_environment`

## Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `name_prefix` | Lowercase prefix used when naming stack resources | `string` | (required) |
| `availability_zones` | Availability zones used for both public and private subnets | `list(string)` | (required) |
| `public_subnet_cidrs` | CIDR blocks for public subnets (one per availability zone) | `list(string)` | (required) |
| `private_subnet_cidrs` | CIDR blocks for private subnets (one per availability zone) | `list(string)` | (required) |
| `vpc_cidr` | Primary CIDR block for the VPC | `string` | `"10.42.0.0/16"` |
| `create_nat_gateway` | Whether to create a NAT Gateway for private subnet internet egress | `bool` | `true` |
| `alb_listener_port` | Port exposed by the internet-facing ALB listener | `number` | `80` |
| `alb_health_check_path` | HTTP path used by the ALB target group health check | `string` | `"/"` |
| `ecs_container_image` | Container image used by the ECS task definition | `string` | `"public.ecr.aws/docker/library/nginx:stable"` |
| `ecs_container_name` | Container name referenced by the ECS service load balancer configuration | `string` | `"app"` |
| `ecs_container_port` | Container port exposed by the ECS task and target group | `number` | `80` |
| `ecs_container_cpu` | CPU units assigned to the ECS task definition | `number` | `256` |
| `ecs_container_memory` | Memory (MiB) assigned to the ECS task definition | `number` | `512` |
| `ecs_container_environment` | Additional environment variables injected into the ECS container | `map(string)` | `{}` |
| `ecs_desired_count` | Desired number of ECS tasks in the service | `number` | `1` |
| `rds_engine` | RDS database engine | `string` | `"postgres"` |
| `rds_engine_version` | RDS engine version. Set to null to let AWS pick the default | `string` | `null` |
| `rds_instance_class` | Instance class for the RDS instance | `string` | `"db.t3.micro"` |
| `rds_allocated_storage` | Allocated storage (GiB) for the RDS instance | `number` | `20` |
| `rds_db_name` | Database name created in the RDS instance | `string` | `"appdb"` |
| `rds_username` | Master username for RDS | `string` | `"appuser"` |
| `rds_password` | Master password for RDS. If null, Terraform generates one | `string` | `null` |
| `rds_port` | Port used by the RDS engine | `number` | `5432` |
| `rds_multi_az` | Whether to deploy RDS in Multi-AZ mode | `bool` | `false` |
| `rds_skip_final_snapshot` | Whether to skip a final snapshot when destroying RDS | `bool` | `true` |
| `tags` | Additional tags applied to all resources | `map(string)` | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| `vpc_id` | ID of the VPC |
| `public_subnet_ids` | Public subnet IDs used by the ALB |
| `private_subnet_ids` | Private subnet IDs used by ECS and RDS |
| `alb_arn` | ARN of the internet-facing ALB |
| `alb_dns_name` | Public DNS name of the internet-facing ALB |
| `alb_security_group_id` | Security group ID attached to the ALB |
| `ecs_cluster_arn` | ARN of the ECS cluster |
| `ecs_cluster_name` | Name of the ECS cluster |
| `ecs_service_name` | Name of the ECS service |
| `ecs_security_group_id` | Security group ID attached to the ECS service |
| `rds_address` | RDS hostname for application connections |
| `rds_port` | RDS port exposed to ECS |
| `rds_db_name` | Database name configured on RDS |
| `rds_security_group_id` | Security group ID attached to RDS |

## Modules

| Module | Path | Provisions |
|--------|------|------------|
| `networking` | [`modules/networking`](modules/networking) | VPC, public/private subnets, Internet Gateway, NAT Gateway |
| `alb` | [`modules/alb`](modules/alb) | Application Load Balancer, target group, HTTP listener, security group |
| `ecs-fargate` | [`modules/ecs-fargate`](modules/ecs-fargate) | ECS cluster, Fargate service, task definition, IAM roles, security group |
| `rds` | [`modules/rds`](modules/rds) | RDS instance, DB subnet group, security group, random password |

## Testing

All tests use Terraform's native test framework with mock providers — no AWS credentials required.

```sh
terraform init -backend=false
terraform test -verbose
```

The test suite includes 36 tests across five test files:

- `modules/networking/tests/networking.tftest.hcl`
- `modules/alb/tests/alb.tftest.hcl`
- `modules/ecs-fargate/tests/ecs_fargate.tftest.hcl`
- `modules/rds/tests/rds.tftest.hcl`
- `tests/integration.tftest.hcl`

## CI/CD

The [GitHub Actions workflow](.github/workflows/terraform.yml) runs five jobs:

1. **Validate** — `terraform fmt -check`, `terraform validate` for each module and root, plus TFLint
2. **Security Scan** — Trivy config scan for HIGH/CRITICAL findings
3. **Test** — Runs `terraform test` for each sub-module in a matrix (networking, alb, ecs-fargate, rds)
4. **Integration Test** — Runs root-level `terraform test` after module tests pass
5. **Plan Examples** — `terraform plan` for minimal and complete examples on pull requests

## Requirements

| Dependency | Version |
|------------|---------|
| Terraform | `>= 1.7.0, < 2.0.0` |
| AWS provider | `~> 5.0` |
| Random provider | `~> 3.6` |
