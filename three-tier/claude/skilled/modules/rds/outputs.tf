output "address" {
  description = "RDS hostname for application connections"
  value       = aws_db_instance.this.address
}

output "port" {
  description = "RDS port exposed to ECS"
  value       = aws_db_instance.this.port
}

output "arn" {
  description = "ARN of the RDS instance"
  value       = aws_db_instance.this.arn
}

output "db_name" {
  description = "Database name configured on RDS"
  value       = aws_db_instance.this.db_name
}

output "username" {
  description = "Master username for RDS"
  value       = aws_db_instance.this.username
}

output "security_group_id" {
  description = "Security group ID attached to RDS"
  value       = aws_security_group.this.id
}
