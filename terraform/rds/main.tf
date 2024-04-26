locals {
  port = var.engine == "mysql" ? 3306 : 5432
}

resource "random_password" "rds_password" {
  length  = 16
  lower   = true
  upper   = true
  numeric = true
  special = false
}

resource "aws_db_instance" "db_instance" {
  storage_type      = "gp3"
  allocated_storage = var.allocated_storage
  engine            = var.engine
  username          = var.username
  password          = random_password.rds_password.result
  db_name           = var.database_name

  engine_version          = var.engine_version
  instance_class          = var.instance_class
  identifier              = var.name
  db_subnet_group_name    = var.db_subnet_group_name
  vpc_security_group_ids  = var.security_group_ids
  skip_final_snapshot     = true
  apply_immediately       = true
  backup_retention_period = 7

  tags = {
    "Name" = var.name
  }
}

resource "aws_security_group" "instance" {
  name        = "${var.name}-instance-sg"
  description = "${var.name} RDS instance security group"
  vpc_id      = var.vpc_id

  tags = {
    "Name" = "${var.name}-instance-sg"
  }
}

resource "aws_security_group_rule" "instance_ingress" {
  type              = "ingress"
  description       = "Self-referencing ingress"
  protocol          = "tcp"
  from_port         = local.port
  to_port           = local.port
  security_group_id = aws_security_group.instance.id
  self              = true
}