data "aws_region" "current" {}

locals {
  name_prefix = lower(var.name_prefix)

  common_tags = merge(
    {
      ManagedBy = "terraform"
      Project   = local.name_prefix
    },
    var.tags
  )
}

resource "aws_security_group" "this" {
  description = "ECS service security group"
  name_prefix = "${local.name_prefix}-ecs-"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow ALB traffic to ECS"
    from_port       = var.container_port
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
    to_port         = var.container_port
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

resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${local.name_prefix}"
  retention_in_days = var.log_retention_in_days

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

resource "aws_iam_role" "task_execution" {
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

resource "aws_iam_role_policy_attachment" "task_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.task_execution.name
}

resource "aws_iam_role" "task" {
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

resource "aws_ecs_task_definition" "this" {
  cpu                      = tostring(var.container_cpu)
  execution_role_arn       = aws_iam_role.task_execution.arn
  family                   = "${local.name_prefix}-task"
  memory                   = tostring(var.container_memory)
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = var.container_image
      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]

      environment = [
        for key, value in var.container_environment : {
          name  = key
          value = value
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
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
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  desired_count                      = var.desired_count
  enable_execute_command             = var.enable_execute_command
  force_new_deployment               = var.force_new_deployment
  health_check_grace_period_seconds  = var.health_check_grace_period_seconds
  launch_type                        = "FARGATE"
  name                               = "${local.name_prefix}-service"
  task_definition                    = aws_ecs_task_definition.this.arn
  wait_for_steady_state              = var.wait_for_steady_state

  deployment_circuit_breaker {
    enable   = var.deployment_circuit_breaker_enable
    rollback = var.deployment_circuit_breaker_rollback
  }

  load_balancer {
    container_name   = var.container_name
    container_port   = var.container_port
    target_group_arn = var.target_group_arn
  }

  network_configuration {
    assign_public_ip = false
    security_groups  = [aws_security_group.this.id]
    subnets          = var.subnet_ids
  }

  depends_on = [var.listener_arn]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-service"
  })
}
