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
  engine                 = var.rds_engine
  engine_version         = var.rds_engine_version
  instance_class         = var.rds_instance_class
  allocated_storage      = var.rds_allocated_storage
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  db_name  = var.db_name
  username = var.db_username
  password = local.effective_db_password
  port     = var.db_port

  publicly_accessible        = false
  skip_final_snapshot        = var.rds_skip_final_snapshot
  backup_retention_period    = var.rds_backup_retention_period
  apply_immediately          = var.rds_apply_immediately
  multi_az                   = var.rds_multi_az
  storage_encrypted          = true
  auto_minor_version_upgrade = true

  tags = merge(local.common_tags, {
    Name = "${var.name}-rds"
  })
}
