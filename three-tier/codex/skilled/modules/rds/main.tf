locals {
  name_prefix = lower(var.name_prefix)

  common_tags = merge(
    {
      ManagedBy = "terraform"
      Project   = local.name_prefix
    },
    var.tags
  )

  password = coalesce(var.password, try(random_password.this[0].result, null))
}

resource "random_password" "this" {
  count = var.password == null ? 1 : 0

  length  = 20
  special = false
}

resource "aws_security_group" "this" {
  description = "RDS security group"
  name_prefix = "${local.name_prefix}-rds-"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow ECS to access RDS"
    from_port       = var.port
    protocol        = "tcp"
    security_groups = [var.ecs_security_group_id]
    to_port         = var.port
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

resource "aws_db_subnet_group" "this" {
  name       = "${local.name_prefix}-db-subnets"
  subnet_ids = var.subnet_ids

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-db-subnets"
  })
}

resource "aws_db_instance" "this" {
  allocated_storage       = var.allocated_storage
  apply_immediately       = var.apply_immediately
  backup_retention_period = var.backup_retention_period
  db_name                 = var.db_name
  db_subnet_group_name    = aws_db_subnet_group.this.name
  deletion_protection     = var.deletion_protection
  engine                  = var.engine
  engine_version          = var.engine_version
  identifier              = substr("${local.name_prefix}-db", 0, 63)
  instance_class          = var.instance_class
  multi_az                = var.multi_az
  password_wo             = local.password
  password_wo_version     = var.password_wo_version
  port                    = var.port
  skip_final_snapshot     = var.skip_final_snapshot
  storage_encrypted       = true
  storage_type            = "gp3"
  username                = var.username
  vpc_security_group_ids  = [aws_security_group.this.id]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-db"
  })
}
