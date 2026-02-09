output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "Primary CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = [for subnet in aws_subnet.private : subnet.id]
}

output "nat_gateway_id" {
  description = "NAT Gateway ID (null if not created)"
  value       = try(aws_nat_gateway.this[0].id, null)
}
