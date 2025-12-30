output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "Public Subnet IDs"
  value       = [for s in aws_subnet.public : s.id]
}

output "private_subnet_ids" {
  description = "Private Subnet IDs"
  value       = [for s in aws_subnet.private : s.id]
}

output "azs" {
  description = "사용한 Availability Zones"
  value       = local.azs
}