resource "aws_secretsmanager_secret" "rds_secret" {
  name_prefix = "${var.name}-rds-secret"
  description = "${var.name} secret for RDS"
}

resource "aws_secretsmanager_secret_version" "rds_secret" {
  secret_id = aws_secretsmanager_secret.rds_secret.id
  secret_string = jsonencode({
    "username"             = var.username
    "password"             = random_password.rds_password.result
    "engine"               = aws_db_instance.db_instance.engine
    "host"                 = aws_db_instance.db_instance.address
    "port"                 = aws_db_instance.db_instance.port
    "dbInstanceIdentifier" = aws_db_instance.db_instance.id
  })
}