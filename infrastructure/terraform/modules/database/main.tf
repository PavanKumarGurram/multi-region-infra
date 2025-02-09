locals {
  db_port = 5432
  db_name = "${var.environment}db"
}

# Global Database Cluster
resource "aws_rds_global_cluster" "main" {
  global_cluster_identifier = "${var.environment}-global-db"
  engine                   = "aurora-postgresql"
  engine_version          = "15.4"
  database_name           = local.db_name
  storage_encrypted       = true
  deletion_protection     = true

  lifecycle {
    prevent_destroy = true
  }
}

# Primary DB Cluster
resource "aws_rds_cluster" "primary" {
  provider                  = aws.primary
  cluster_identifier        = "${var.environment}-primary"
  engine                   = aws_rds_global_cluster.main.engine
  engine_version           = aws_rds_global_cluster.main.engine_version
  global_cluster_identifier = aws_rds_global_cluster.main.id
  database_name            = local.db_name
  master_username          = var.master_username
  master_password          = var.master_password
  port                     = local.db_port

  db_subnet_group_name     = aws_db_subnet_group.primary.name
  vpc_security_group_ids   = [aws_security_group.primary.id]

  backup_retention_period  = 7
  preferred_backup_window = "03:00-04:00"
  skip_final_snapshot     = false
  final_snapshot_identifier = "${var.environment}-primary-final"

  enabled_cloudwatch_logs_exports = ["postgresql"]
  apply_immediately             = false

  lifecycle {
    prevent_destroy = true
  }

  tags = var.tags
}

# Secondary DB Cluster
resource "aws_rds_cluster" "secondary" {
  provider                  = aws.secondary
  cluster_identifier        = "${var.environment}-secondary"
  engine                   = aws_rds_global_cluster.main.engine
  engine_version           = aws_rds_global_cluster.main.engine_version
  global_cluster_identifier = aws_rds_global_cluster.main.id
  port                     = local.db_port

  db_subnet_group_name     = aws_db_subnet_group.secondary.name
  vpc_security_group_ids   = [aws_security_group.secondary.id]

  backup_retention_period  = 7
  preferred_backup_window = "03:00-04:00"
  skip_final_snapshot     = false
  final_snapshot_identifier = "${var.environment}-secondary-final"

  enabled_cloudwatch_logs_exports = ["postgresql"]
  apply_immediately             = false

  lifecycle {
    prevent_destroy = true
  }

  tags = var.tags

  depends_on = [aws_rds_cluster.primary]
}

# Primary DB Instances
resource "aws_rds_cluster_instance" "primary" {
  provider                = aws.primary
  count                  = var.primary_instance_count
  identifier             = "${var.environment}-primary-${count.index + 1}"
  cluster_identifier     = aws_rds_cluster.primary.id
  instance_class         = var.instance_class
  engine                 = aws_rds_cluster.primary.engine
  engine_version         = aws_rds_cluster.primary.engine_version
  db_subnet_group_name   = aws_db_subnet_group.primary.name
  
  performance_insights_enabled = true
  monitoring_interval         = 60
  monitoring_role_arn         = aws_iam_role.monitoring.arn

  auto_minor_version_upgrade  = true
  
  tags = var.tags
}

# Secondary DB Instances
resource "aws_rds_cluster_instance" "secondary" {
  provider                = aws.secondary
  count                  = var.secondary_instance_count
  identifier             = "${var.environment}-secondary-${count.index + 1}"
  cluster_identifier     = aws_rds_cluster.secondary.id
  instance_class         = var.instance_class
  engine                 = aws_rds_cluster.secondary.engine
  engine_version         = aws_rds_cluster.secondary.engine_version
  db_subnet_group_name   = aws_db_subnet_group.secondary.name
  
  performance_insights_enabled = true
  monitoring_interval         = 60
  monitoring_role_arn         = aws_iam_role.monitoring.arn

  auto_minor_version_upgrade  = true
  
  tags = var.tags
}

# Primary DB Subnet Group
resource "aws_db_subnet_group" "primary" {
  provider    = aws.primary
  name        = "${var.environment}-primary-subnet-group"
  subnet_ids  = var.primary_subnet_ids
  
  tags = var.tags
}

# Secondary DB Subnet Group
resource "aws_db_subnet_group" "secondary" {
  provider    = aws.secondary
  name        = "${var.environment}-secondary-subnet-group"
  subnet_ids  = var.secondary_subnet_ids
  
  tags = var.tags
}