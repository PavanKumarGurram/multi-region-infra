output "primary_cluster_endpoint" {
  description = "Writer endpoint for the primary DB cluster"
  value       = aws_rds_cluster.primary.endpoint
}

output "primary_cluster_reader_endpoint" {
  description = "Reader endpoint for the primary DB cluster"
  value       = aws_rds_cluster.primary.reader_endpoint
}

output "secondary_cluster_endpoint" {
  description = "Writer endpoint for the secondary DB cluster"
  value       = aws_rds_cluster.secondary.endpoint
}

output "secondary_cluster_reader_endpoint" {
  description = "Reader endpoint for the secondary DB cluster"
  value       = aws_rds_cluster.secondary.reader_endpoint
}

output "database_name" {
  description = "Name of the database"
  value       = local.db_name
}

output "primary_security_group_id" {
  description = "ID of the primary database security group"
  value       = aws_security_group.primary.id
}

output "secondary_security_group_id" {
  description = "ID of the secondary database security group"
  value       = aws_security_group.secondary.id
}