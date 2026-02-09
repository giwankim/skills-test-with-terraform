data "aws_region" "current" {}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.name}"
  retention_in_days = var.log_retention_days

  tags = local.common_tags
}

resource "aws_ecs_cluster" "this" {
  name = "${var.name}-cluster"

  tags = merge(local.common_tags, {
    Name = "${var.name}-cluster"
  })
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = tostring(var.task_cpu)
  memory                   = tostring(var.task_memory)
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = "app"
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
        {
          name  = "DB_HOST"
          value = aws_db_instance.this.address
        },
        {
          name  = "DB_PORT"
          value = tostring(var.db_port)
        },
        {
          name  = "DB_NAME"
          value = var.db_name
        },
        {
          name  = "DB_USER"
          value = var.db_username
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = data.aws_region.current.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = merge(local.common_tags, {
    Name = "${var.name}-task-def"
  })
}

resource "aws_ecs_service" "this" {
  name            = "${var.name}-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  deployment_minimum_healthy_percent = var.deployment_min_healthy_pct
  deployment_maximum_percent         = var.deployment_max_pct
  health_check_grace_period_seconds  = var.health_check_grace_period

  deployment_circuit_breaker {
    enable   = var.enable_circuit_breaker
    rollback = var.enable_circuit_breaker
  }

  network_configuration {
    assign_public_ip = false
    security_groups  = [aws_security_group.ecs.id]
    subnets          = values(aws_subnet.private)[*].id
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = "app"
    container_port   = var.container_port
  }

  depends_on = [aws_lb_listener.this]

  tags = merge(local.common_tags, {
    Name = "${var.name}-service"
  })
}
