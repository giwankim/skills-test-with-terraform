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

output "rds_address" {
  description = "RDS hostname"
  value       = module.three_tier.rds_address
}
