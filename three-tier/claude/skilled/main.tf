locals {
  task_environment = merge(
    {
      DB_HOST = module.rds.address
      DB_NAME = module.rds.db_name
      DB_PORT = tostring(module.rds.port)
    },
    var.ecs_container_environment
  )
}

module "networking" {
  source = "./modules/networking"

  name_prefix          = var.name_prefix
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  create_nat_gateway   = var.create_nat_gateway
  tags                 = var.tags
}

module "alb" {
  source = "./modules/alb"

  name_prefix       = var.name_prefix
  vpc_id            = module.networking.vpc_id
  subnet_ids        = module.networking.public_subnet_ids
  listener_port     = var.alb_listener_port
  target_group_port = var.ecs_container_port
  health_check_path = var.alb_health_check_path
  tags              = var.tags
}

module "ecs_fargate" {
  source = "./modules/ecs-fargate"

  name_prefix           = var.name_prefix
  vpc_id                = module.networking.vpc_id
  subnet_ids            = module.networking.private_subnet_ids
  alb_security_group_id = module.alb.security_group_id
  target_group_arn      = module.alb.target_group_arn
  listener_arn          = module.alb.listener_arn
  container_image       = var.ecs_container_image
  container_name        = var.ecs_container_name
  container_port        = var.ecs_container_port
  container_cpu         = var.ecs_container_cpu
  container_memory      = var.ecs_container_memory
  container_environment = local.task_environment
  desired_count         = var.ecs_desired_count
  tags                  = var.tags
}

module "rds" {
  source = "./modules/rds"

  name_prefix           = var.name_prefix
  vpc_id                = module.networking.vpc_id
  subnet_ids            = module.networking.private_subnet_ids
  ecs_security_group_id = module.ecs_fargate.security_group_id
  engine                = var.rds_engine
  engine_version        = var.rds_engine_version
  instance_class        = var.rds_instance_class
  allocated_storage     = var.rds_allocated_storage
  db_name               = var.rds_db_name
  username              = var.rds_username
  password              = var.rds_password
  port                  = var.rds_port
  multi_az              = var.rds_multi_az
  skip_final_snapshot   = var.rds_skip_final_snapshot
  tags                  = var.tags
}
