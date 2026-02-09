resource "aws_security_group" "alb" {
  name_prefix = "${var.name}-alb-"
  description = "ALB security group"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "Allow public ingress on listener port"
    from_port   = var.alb_listener_port
    to_port     = var.alb_listener_port
    protocol    = "tcp"
    cidr_blocks = var.alb_ingress_cidrs
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.name}-alb-sg"
  })
}

resource "aws_security_group" "ecs" {
  name_prefix = "${var.name}-ecs-"
  description = "ECS task security group"
  vpc_id      = aws_vpc.this.id

  ingress {
    description     = "Allow ALB to reach ECS tasks"
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.name}-ecs-sg"
  })
}

resource "aws_security_group" "rds" {
  name_prefix = "${var.name}-rds-"
  description = "RDS security group"
  vpc_id      = aws_vpc.this.id

  ingress {
    description     = "Allow ECS tasks to access RDS"
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.name}-rds-sg"
  })
}
