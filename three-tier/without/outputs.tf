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

output "ecs_cluster_arn" {
  description = "ECS cluster ARN."
  value       = aws_ecs_cluster.this.arn
}

output "ecs_service_name" {
  description = "ECS service name."
  value       = aws_ecs_service.this.name
}

output "rds_endpoint" {
  description = "RDS instance endpoint address."
  value       = aws_db_instance.this.address
}

output "rds_port" {
  description = "RDS port."
  value       = aws_db_instance.this.port
}

output "alb_security_group_id" {
  description = "Security group attached to ALB."
  value       = aws_security_group.alb.id
}

output "ecs_security_group_id" {
  description = "Security group attached to ECS tasks."
  value       = aws_security_group.ecs.id
}

output "rds_security_group_id" {
  description = "Security group attached to RDS instance."
  value       = aws_security_group.rds.id
}
