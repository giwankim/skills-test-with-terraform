resource "random_password" "db" {
  count = var.db_password == null ? 1 : 0

  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-db-subnets"
  subnet_ids = values(aws_subnet.private)[*].id

  tags = merge(local.common_tags, {
    Name = "${var.name}-db-subnets"
  })
}

resource "aws_db_instance" "this" {
  identifier_prefix      = substr("${var.name}-db-", 0, 54)
  engine                 = var.db_engine
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_allocated_storage
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  db_name  = var.db_name
  username = var.db_username
  password = local.effective_db_password
  port     = var.db_port

  publicly_accessible     = false
  skip_final_snapshot     = true
  backup_retention_period = var.db_backup_retention
  apply_immediately       = var.db_apply_immediately
  multi_az                = var.db_multi_az
  storage_encrypted       = var.db_storage_encrypted

  tags = merge(local.common_tags, {
    Name = "${var.name}-rds"
  })
}
