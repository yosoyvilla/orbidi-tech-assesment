output "vpc_id" {
  description = "The VPC ID."
  value       = aws_vpc.vpc.id
}

output "cidr_block" {
  description = "The main CIDR block for the VPC."
  value       = aws_vpc.vpc.cidr_block
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "The IDS of the private subnets."
  value       = aws_subnet.private[*].id
}

output "db_subnet_group_name" {
  description = "The main RDS DB subnet group for the VPC."
  value       = aws_db_subnet_group.db_subnet_group.name
}