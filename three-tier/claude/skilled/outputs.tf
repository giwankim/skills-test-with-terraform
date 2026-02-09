output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs used by the ALB"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs used by ECS and RDS"
  value       = module.networking.private_subnet_ids
}

output "alb_arn" {
  description = "ARN of the internet-facing ALB"
  value       = module.alb.alb_arn
}

output "alb_dns_name" {
  description = "Public DNS name of the internet-facing ALB"
  value       = module.alb.alb_dns_name
}

output "alb_security_group_id" {
  description = "Security group ID attached to the ALB"
  value       = module.alb.security_group_id
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = module.ecs_fargate.cluster_arn
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs_fargate.cluster_name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = module.ecs_fargate.service_name
}

output "ecs_security_group_id" {
  description = "Security group ID attached to the ECS service"
  value       = module.ecs_fargate.security_group_id
}

output "rds_address" {
  description = "RDS hostname for application connections"
  value       = module.rds.address
}

output "rds_port" {
  description = "RDS port exposed to ECS"
  value       = module.rds.port
}

output "rds_db_name" {
  description = "Database name configured on RDS"
  value       = module.rds.db_name
}

output "rds_security_group_id" {
  description = "Security group ID attached to RDS"
  value       = module.rds.security_group_id
}
