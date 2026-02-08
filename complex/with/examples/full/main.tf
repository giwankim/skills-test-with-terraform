terraform {
  required_version = ">= 1.7.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "stack" {
  source = "../.."

  alb_health_check_path = "/health"
  availability_zones    = var.availability_zones
  name_prefix           = var.name_prefix

  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
  vpc_cidr             = var.vpc_cidr

  ecs_container_cpu    = 512
  ecs_container_image  = "public.ecr.aws/docker/library/nginx:stable"
  ecs_container_memory = 1024
  ecs_desired_count    = 2

  ecs_deployment_circuit_breaker_enable   = true
  ecs_deployment_circuit_breaker_rollback = true
  ecs_deployment_maximum_percent          = 300
  ecs_deployment_minimum_healthy_percent  = 100
  ecs_force_new_deployment                = true
  ecs_health_check_grace_period_seconds   = 120

  ecs_container_environment = {
    APP_ENV   = "production"
    LOG_LEVEL = "info"
  }

  rds_allocated_storage       = 50
  rds_apply_immediately       = true
  rds_backup_retention_period = 7
  rds_db_name                 = "appdb"
  rds_instance_class          = "db.t3.micro"
  rds_multi_az                = false
  rds_password                = var.rds_password
  rds_skip_final_snapshot     = true
  rds_username                = "appuser"

  s3_versioning_enabled = true

  tags = {
    Environment = "full"
    Example     = "full"
    Owner       = "platform-team"
  }
}
