output "vpc_id" {
  description = "VPC ID."
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs."
  value       = values(aws_subnet.public)[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs."
  value       = values(aws_subnet.private)[*].id
}

output "alb_arn" {
  description = "ALB ARN."
  value       = aws_lb.this.arn
}

output "alb_dns_name" {
  description = "ALB DNS name."
  value       = aws_lb.this.dns_name
}

output "alb_target_group_arn" {
  description = "ALB target group ARN used by ECS service."
  value       = aws_lb_target_group.ecs.arn
}

output "ecs_cluster_arn" {
  description = "ECS cluster ARN."
  value       = aws_ecs_cluster.this.arn
}

output "ecs_service_name" {
  description = "ECS service name."
  value       = aws_ecs_service.this.name
}

output "ecs_security_group_id" {
  description = "Security group attached to ECS tasks."
  value       = aws_security_group.ecs.id
}

output "rds_endpoint" {
  description = "RDS instance endpoint address for ECS connectivity."
  value       = aws_db_instance.this.address
}

output "rds_port" {
  description = "RDS port for ECS connectivity."
  value       = aws_db_instance.this.port
}

output "rds_security_group_id" {
  description = "Security group attached to RDS instance."
  value       = aws_security_group.rds.id
}

output "db_name" {
  description = "Database name configured on RDS."
  value       = aws_db_instance.this.db_name
}

output "db_username" {
  description = "Database username configured on RDS."
  value       = aws_db_instance.this.username
}

output "s3_bucket_id" {
  description = "S3 bucket ID."
  value       = aws_s3_bucket.this.id
}

output "s3_bucket_name" {
  description = "S3 bucket name."
  value       = aws_s3_bucket.this.bucket
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN."
  value       = aws_s3_bucket.this.arn
}
