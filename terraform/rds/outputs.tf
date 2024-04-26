output "rds_endpoint" {
  description = "The RDS endpoint."
  value       = aws_db_instance.db_instance.endpoint
}

output "instance_security_group_id" {
  description = "The RDS instance security group ID."
  value       = aws_security_group.instance.id
}

output "credentials_secret_id" {
  description = "The Secrets Manager secret ID that holds the instance credentials."
  value       = aws_secretsmanager_secret.rds_secret.id
}

output "credentials_secret_arn" {
  description = "The Secrets Manager secret ARN that holds the instance credentials."
  value       = aws_secretsmanager_secret.rds_secret.arn
}

output "identifier" {
  description = "The RDS instance identifier."
  value       = aws_db_instance.db_instance.identifier
}