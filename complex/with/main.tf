data "aws_region" "current" {}

check "at_least_two_azs" {
  assert {
    condition     = length(var.availability_zones) >= 2
    error_message = "availability_zones must include at least two AZs for an internet-facing ALB."
  }
}

check "public_subnet_count_matches_azs" {
  assert {
    condition     = length(var.public_subnet_cidrs) == length(var.availability_zones)
    error_message = "public_subnet_cidrs must match availability_zones length."
  }
}

check "private_subnet_count_matches_azs" {
  assert {
    condition     = length(var.private_subnet_cidrs) == length(var.availability_zones)
    error_message = "private_subnet_cidrs must match availability_zones length."
  }
}

locals {
  name_prefix = lower(var.name_prefix)

  common_tags = merge(
    {
      ManagedBy = "terraform"
      Project   = local.name_prefix
    },
    var.tags
  )

  public_subnets = {
    for index, az in var.availability_zones : az => {
      availability_zone = az
      cidr_block        = try(var.public_subnet_cidrs[index], null)
    }
  }

  private_subnets = {
    for index, az in var.availability_zones : az => {
      availability_zone = az
      cidr_block        = try(var.private_subnet_cidrs[index], null)
    }
  }

  rds_password = coalesce(var.rds_password, try(random_password.rds[0].result, null))

  s3_bucket_name = coalesce(
    var.s3_bucket_name,
    try("${local.name_prefix}-${random_string.bucket_suffix[0].result}", null)
  )

  task_environment = merge(
    {
      DB_HOST   = aws_db_instance.this.address
      DB_NAME   = var.rds_db_name
      DB_PORT   = tostring(var.rds_port)
      S3_BUCKET = local.s3_bucket_name
    },
    var.ecs_container_environment
  )
}

resource "random_password" "rds" {
  count = var.rds_password == null ? 1 : 0

  length  = 20
  special = false
}

resource "random_string" "bucket_suffix" {
  count = var.s3_bucket_name == null ? 1 : 0

  length  = 10
  lower   = true
  numeric = true
  special = false
  upper   = false
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc"
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-igw"
  })
}

resource "aws_subnet" "public" {
  for_each = local.public_subnets

  availability_zone       = each.value.availability_zone
  cidr_block              = each.value.cidr_block
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-${each.value.availability_zone}"
    Tier = "public"
  })
}

resource "aws_subnet" "private" {
  for_each = local.private_subnets

  availability_zone       = each.value.availability_zone
  cidr_block              = each.value.cidr_block
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-private-${each.value.availability_zone}"
    Tier = "private"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-rt"
  })
}

resource "aws_route" "public_default" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
  route_table_id         = aws_route_table.public.id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  route_table_id = aws_route_table.public.id
  subnet_id      = each.value.id
}

resource "aws_eip" "nat" {
  count = var.create_nat_gateway ? 1 : 0

  domain = "vpc"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-nat-eip"
  })
}

resource "aws_nat_gateway" "this" {
  count = var.create_nat_gateway ? 1 : 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[var.availability_zones[0]].id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-nat"
  })

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "private" {
  for_each = aws_subnet.private

  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-private-rt-${each.key}"
  })
}

resource "aws_route" "private_default" {
  for_each = var.create_nat_gateway ? aws_route_table.private : {}

  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[0].id
  route_table_id         = each.value.id
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  route_table_id = aws_route_table.private[each.key].id
  subnet_id      = each.value.id
}

resource "aws_security_group" "alb" {
  description = "Internet-facing ALB security group"
  name_prefix = "${local.name_prefix}-alb-"
  vpc_id      = aws_vpc.this.id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow inbound HTTP"
    from_port   = var.alb_listener_port
    protocol    = "tcp"
    to_port     = var.alb_listener_port
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-alb-sg"
  })
}

resource "aws_security_group" "ecs" {
  description = "ECS service security group"
  name_prefix = "${local.name_prefix}-ecs-"
  vpc_id      = aws_vpc.this.id

  ingress {
    description     = "Allow ALB traffic to ECS"
    from_port       = var.ecs_container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
    to_port         = var.ecs_container_port
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ecs-sg"
  })
}

resource "aws_security_group" "rds" {
  description = "RDS security group"
  name_prefix = "${local.name_prefix}-rds-"
  vpc_id      = aws_vpc.this.id

  ingress {
    description     = "Allow ECS to access RDS"
    from_port       = var.rds_port
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
    to_port         = var.rds_port
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-rds-sg"
  })
}

resource "aws_lb" "this" {
  internal           = false
  load_balancer_type = "application"
  name               = substr("${local.name_prefix}-alb", 0, 32)
  security_groups    = [aws_security_group.alb.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-alb"
  })
}

resource "aws_lb_target_group" "ecs" {
  name        = substr("${local.name_prefix}-tg", 0, 32)
  port        = var.alb_target_group_port
  protocol    = var.alb_target_group_protocol
  target_type = "ip"
  vpc_id      = aws_vpc.this.id

  health_check {
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200-399"
    path                = var.alb_health_check_path
    protocol            = var.alb_target_group_protocol
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-tg"
  })
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.alb_listener_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.ecs.arn
    type             = "forward"
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-http-listener"
  })
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${local.name_prefix}"
  retention_in_days = var.ecs_log_retention_in_days

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ecs-logs"
  })
}

resource "aws_ecs_cluster" "this" {
  name = "${local.name_prefix}-cluster"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-cluster"
  })
}

resource "aws_iam_role" "ecs_task_execution" {
  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
    Version = "2012-10-17"
  })
  name = substr("${local.name_prefix}-ecs-exec", 0, 64)

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ecs-exec-role"
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_task_execution.name
}

resource "aws_iam_role" "ecs_task" {
  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
    Version = "2012-10-17"
  })
  name = substr("${local.name_prefix}-ecs-task", 0, 64)

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ecs-task-role"
  })
}

resource "aws_iam_role_policy" "ecs_task_s3_access" {
  name = substr("${local.name_prefix}-ecs-s3", 0, 128)
  policy = jsonencode({
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject"
        ]
        Effect = "Allow"
        Resource = [
          aws_s3_bucket.this.arn,
          "${aws_s3_bucket.this.arn}/*"
        ]
      }
    ]
    Version = "2012-10-17"
  })
  role = aws_iam_role.ecs_task.id
}

resource "aws_ecs_task_definition" "this" {
  cpu                      = tostring(var.ecs_container_cpu)
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  family                   = "${local.name_prefix}-task"
  memory                   = tostring(var.ecs_container_memory)
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = var.ecs_container_name
      image     = var.ecs_container_image
      essential = true

      portMappings = [
        {
          containerPort = var.ecs_container_port
          hostPort      = var.ecs_container_port
          protocol      = "tcp"
        }
      ]

      environment = [
        for key, value in local.task_environment : {
          name  = key
          value = value
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-task"
  })
}

resource "aws_ecs_service" "this" {
  cluster                            = aws_ecs_cluster.this.id
  deployment_maximum_percent         = var.ecs_deployment_maximum_percent
  deployment_minimum_healthy_percent = var.ecs_deployment_minimum_healthy_percent
  desired_count                      = var.ecs_desired_count
  enable_execute_command             = var.ecs_enable_execute_command
  force_new_deployment               = var.ecs_force_new_deployment
  health_check_grace_period_seconds  = var.ecs_health_check_grace_period_seconds
  launch_type                        = "FARGATE"
  name                               = "${local.name_prefix}-service"
  task_definition                    = aws_ecs_task_definition.this.arn
  wait_for_steady_state              = var.ecs_wait_for_steady_state

  deployment_circuit_breaker {
    enable   = var.ecs_deployment_circuit_breaker_enable
    rollback = var.ecs_deployment_circuit_breaker_rollback
  }

  load_balancer {
    container_name   = var.ecs_container_name
    container_port   = var.ecs_container_port
    target_group_arn = aws_lb_target_group.ecs.arn
  }

  network_configuration {
    assign_public_ip = false
    security_groups  = [aws_security_group.ecs.id]
    subnets          = [for subnet in aws_subnet.private : subnet.id]
  }

  depends_on = [aws_lb_listener.http]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-service"
  })
}

resource "aws_db_subnet_group" "this" {
  name       = "${local.name_prefix}-db-subnets"
  subnet_ids = [for subnet in aws_subnet.private : subnet.id]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-db-subnets"
  })
}

resource "aws_db_instance" "this" {
  allocated_storage       = var.rds_allocated_storage
  apply_immediately       = var.rds_apply_immediately
  backup_retention_period = var.rds_backup_retention_period
  db_name                 = var.rds_db_name
  db_subnet_group_name    = aws_db_subnet_group.this.name
  deletion_protection     = var.rds_deletion_protection
  engine                  = var.rds_engine
  engine_version          = var.rds_engine_version
  identifier              = substr("${local.name_prefix}-db", 0, 63)
  instance_class          = var.rds_instance_class
  multi_az                = var.rds_multi_az
  password                = local.rds_password
  port                    = var.rds_port
  skip_final_snapshot     = var.rds_skip_final_snapshot
  storage_encrypted       = true
  storage_type            = "gp3"
  username                = var.rds_username
  vpc_security_group_ids  = [aws_security_group.rds.id]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-db"
  })
}

resource "aws_s3_bucket" "this" {
  bucket        = local.s3_bucket_name
  force_destroy = var.s3_force_destroy

  tags = merge(local.common_tags, {
    Name = local.s3_bucket_name
  })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  block_public_acls       = true
  block_public_policy     = true
  bucket                  = aws_s3_bucket.this.id
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.s3_versioning_enabled ? "Enabled" : "Suspended"
  }
}
