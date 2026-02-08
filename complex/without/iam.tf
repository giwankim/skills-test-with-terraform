locals {
  ecs_task_assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  ecs_task_s3_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.this.arn,
          "${aws_s3_bucket.this.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "ecs_task_execution" {
  name_prefix        = "${var.name}-ecs-exec-"
  assume_role_policy = local.ecs_task_assume_role_policy

  tags = merge(local.common_tags, {
    Name = "${var.name}-ecs-exec-role"
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task" {
  name_prefix        = "${var.name}-ecs-task-"
  assume_role_policy = local.ecs_task_assume_role_policy

  tags = merge(local.common_tags, {
    Name = "${var.name}-ecs-task-role"
  })
}

resource "aws_iam_role_policy" "ecs_task_s3" {
  name_prefix = "${var.name}-ecs-s3-"
  role        = aws_iam_role.ecs_task.id
  policy      = local.ecs_task_s3_policy
}
