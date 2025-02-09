# Infrastructure Configuration Guide

This guide details all the values that need to be replaced in the infrastructure code for it to work in your environment.

## Core Configuration Files

### 1. Backend Configuration (`infrastructure/terraform/main.tf`)

```hcl
backend "s3" {
  bucket         = "your-terraform-state-bucket"  # Replace with your S3 bucket name
  key            = "terraform.tfstate"
  region         = "us-east-1"                    # Replace with your desired region
  dynamodb_table = "terraform-state-lock"         # Replace with your DynamoDB table name
}
```

### 2. Environment Variables (`infrastructure/terraform/prod.tfvars`)

Create this file with the following variables:

```hcl
environment = "prod"  # Or your desired environment name

# Regions
primary_region   = "us-east-1"  # Replace with your primary region
secondary_region = "us-west-2"  # Replace with your secondary region

# VPC Configuration
primary_vpc_cidr   = "10.0.0.0/16"  # Adjust CIDR range as needed
secondary_vpc_cidr = "10.1.0.0/16"  # Adjust CIDR range as needed

# Availability Zones
primary_azs   = ["us-east-1a", "us-east-1b", "us-east-1c"]    # Replace with your primary region AZs
secondary_azs = ["us-west-2a", "us-west-2b", "us-west-2c"]    # Replace with your secondary region AZs

# Subnet Configuration
primary_private_subnets = [
  "10.0.1.0/24",
  "10.0.2.0/24",
  "10.0.3.0/24"
]

primary_public_subnets = [
  "10.0.101.0/24",
  "10.0.102.0/24",
  "10.0.103.0/24"
]

secondary_private_subnets = [
  "10.1.1.0/24",
  "10.1.2.0/24",
  "10.1.3.0/24"
]

secondary_public_subnets = [
  "10.1.101.0/24",
  "10.1.102.0/24",
  "10.1.103.0/24"
]
```

## Module-Specific Configurations

### 1. Database Module

In `infrastructure/terraform/modules/database/main.tf`:

```hcl
# Replace these sensitive values with secure passwords
master_username = "admin"          # Store in AWS Secrets Manager
master_password = "your-password"  # Store in AWS Secrets Manager

# Adjust instance specifications
instance_class = "db.r6g.large"    # Choose based on your requirements
```

### 2. CDN Module

In `infrastructure/terraform/modules/cdn/main.tf`:

```hcl
# Replace with your domain
domain_name = "example.com"  # Your actual domain name

# WAF Configuration
blocked_countries = []  # Add country codes to block if needed
```

### 3. Application Module

In `infrastructure/terraform/modules/application/main.tf`:

```hcl
# AMI ID
ami_id = "ami-12345678"  # Replace with your desired AMI ID

# Instance Configuration
instance_type = "t3.micro"  # Adjust based on your needs

# Auto Scaling Configuration
asg_desired_capacity = 2
asg_max_size        = 4
asg_min_size        = 1
```

### 4. Monitoring Module

In `infrastructure/terraform/modules/monitoring/main.tf`:

```hcl
# Budget Configuration
budgets_budget "monthly" {
  limit_amount = "1000"  # Replace with your budget limit
  subscriber_email_addresses = ["your-email@example.com"]  # Replace with alert recipients
}

# Backup Configuration
backup_plan "main" {
  rule {
    schedule = "cron(0 5 ? * * *)"  # Adjust backup schedule
    lifecycle {
      delete_after = 30  # Adjust retention period
    }
  }
}
```

## Security Configurations

### 1. SSL/TLS Certificates

Ensure you have:
- ACM certificates in the primary region for ALB
- ACM certificates in us-east-1 for CloudFront
- Valid domain in Route 53

### 2. IAM Roles

Review and adjust all IAM roles and policies in:
- `modules/application/security.tf`
- `modules/database/security.tf`

### 3. Security Groups

Review and adjust security group rules in:
- `modules/application/security.tf`
- `modules/database/security.tf`

## Cost Management

### 1. Resource Tags

In `infrastructure/terraform/variables.tf`, adjust the default tags:

```hcl
variable "tags" {
  default = {
    Environment = "prod"
    Project     = "your-project-name"
    CostCenter  = "your-cost-center"
    Owner       = "your-team"
  }
}
```

### 2. Budget Alerts

In `modules/monitoring/main.tf`, adjust the budget configuration:

```hcl
aws_budgets_budget "monthly" {
  limit_amount      = "1000"  # Your monthly budget limit
  subscriber_email_addresses = [
    "primary@example.com",
    "secondary@example.com"
  ]
}
```

## Required AWS Resources

Before deploying, ensure you have:

1. **S3 Bucket for Terraform State**
   - Create a bucket with versioning enabled
   - Enable encryption
   - Configure appropriate bucket policies

2. **DynamoDB Table for State Locking**
   - Create table with partition key "LockID"
   - Configure appropriate IAM permissions

3. **Route 53 Hosted Zone**
   - Register your domain or configure existing domain
   - Set up NS records if using external registrar

4. **ACM Certificates**
   - Request certificates for your domain
   - Complete domain validation
   - One in primary region for ALB
   - One in us-east-1 for CloudFront

5. **IAM User/Role for Terraform**
   - Create with appropriate permissions
   - Configure AWS credentials locally

## Post-Deployment Configuration

After successful deployment:

1. **DNS Configuration**
   - Update nameservers at your domain registrar
   - Verify DNS propagation

2. **Monitoring Setup**
   - Configure CloudWatch dashboard widgets
   - Set up alert notifications
   - Test backup and restore procedures

3. **Load Balancer**
   - Configure health checks
   - Set up SSL termination
   - Configure access logs

4. **Database**
   - Configure parameter groups
   - Set up automated snapshots
   - Configure read replicas if needed

## Sensitive Information Management

NEVER commit sensitive information to version control:

1. Use AWS Secrets Manager or Parameter Store for:
   - Database credentials
   - API keys
   - Service accounts

2. Use environment-specific `.tfvars` files for:
   - Resource sizing
   - Environment-specific configurations
   - Keep these files out of version control

3. Use AWS KMS for:
   - Database encryption
   - Backup encryption
   - Application secrets