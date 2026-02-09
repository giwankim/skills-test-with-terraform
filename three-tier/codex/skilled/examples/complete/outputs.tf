output "vpc_id" {
  description = "ID of the VPC"
  value       = module.three_tier.vpc_id
}

output "alb_dns_name" {
  description = "Public DNS name of the ALB"
  value       = module.three_tier.alb_dns_name
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.three_tier.ecs_cluster_name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = module.three_tier.ecs_service_name
}

output "rds_address" {
  description = "RDS hostname"
  value       = module.three_tier.rds_address
}

output "rds_port" {
  description = "RDS port"
  value       = module.three_tier.rds_port
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.three_tier.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.three_tier.private_subnet_ids
}
