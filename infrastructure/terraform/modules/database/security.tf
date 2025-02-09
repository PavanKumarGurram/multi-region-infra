# Primary DB Security Group
resource "aws_security_group" "primary" {
  provider    = aws.primary
  name_prefix = "${var.environment}-primary-db-sg"
  vpc_id      = var.primary_vpc_id

  ingress {
    from_port       = local.db_port
    to_port         = local.db_port
    protocol        = "tcp"
    security_groups = var.primary_app_security_group_ids
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-primary-db-sg"
    }
  )
}

# Secondary DB Security Group
resource "aws_security_group" "secondary" {
  provider    = aws.secondary
  name_prefix = "${var.environment}-secondary-db-sg"
  vpc_id      = var.secondary_vpc_id

  ingress {
    from_port       = local.db_port
    to_port         = local.db_port
    protocol        = "tcp"
    security_groups = var.secondary_app_security_group_ids
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-secondary-db-sg"
    }
  )
}

# Enhanced Monitoring IAM Role
resource "aws_iam_role" "monitoring" {
  name = "${var.environment}-db-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "monitoring" {
  role       = aws_iam_role.monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# KMS Key for Database Encryption
resource "aws_kms_key" "database" {
  provider                = aws.primary
  description             = "KMS key for database encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  multi_region           = true

  tags = var.tags
}

resource "aws_kms_alias" "database" {
  provider      = aws.primary
  name          = "alias/${var.environment}-database"
  target_key_id = aws_kms_key.database.key_id
}