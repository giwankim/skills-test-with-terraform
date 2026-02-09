provider "aws" {
  region = var.region
}

module "three_tier" {
  source = "../../"

  name_prefix          = "complete-${var.environment}"
  availability_zones   = ["${var.region}a", "${var.region}b", "${var.region}c"]
  vpc_cidr             = "10.99.0.0/16"
  public_subnet_cidrs  = ["10.99.0.0/24", "10.99.1.0/24", "10.99.2.0/24"]
  private_subnet_cidrs = ["10.99.10.0/24", "10.99.11.0/24", "10.99.12.0/24"]
  create_nat_gateway   = true

  alb_listener_port     = 80
  alb_health_check_path = "/healthz"

  ecs_container_image  = "public.ecr.aws/docker/library/nginx:stable"
  ecs_container_name   = "web"
  ecs_container_port   = 80
  ecs_container_cpu    = 512
  ecs_container_memory = 1024
  ecs_desired_count    = 2
  ecs_container_environment = {
    APP_ENV = var.environment
  }

  rds_engine            = "postgres"
  rds_instance_class    = "db.t3.small"
  rds_allocated_storage = 50
  rds_multi_az          = true
  rds_db_name           = "webapp"
  rds_username          = "webadmin"

  tags = {
    Environment = var.environment
    Example     = "complete"
  }
}
