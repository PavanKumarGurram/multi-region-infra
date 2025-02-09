# Multi-Region High Availability Infrastructure

This repository contains the infrastructure as code (IaC) for a highly available, multi-region application deployment using AWS services and Terraform.

## Architecture Overview

The infrastructure is designed with the following key principles:
- Multi-region deployment for high availability
- Active-passive configuration with automated failover
- Secure by default with encryption at rest and in transit
- Comprehensive monitoring and alerting
- Automated backup and disaster recovery
- Cost optimization and management

### Key Components

1. **Networking (VPC)**
   - Isolated network environments in each region
   - Public and private subnets across multiple AZs
   - NAT Gateways for private subnet internet access
   - Network ACLs and Security Groups for access control

2. **Application Layer**
   - Application Load Balancers for traffic distribution
   - Auto Scaling Groups for dynamic capacity management
   - EC2 instances in private subnets
   - Health checks and automated instance replacement

3. **Database Layer**
   - Aurora Global Database for cross-region replication
   - Automated failover capabilities
   - Encrypted storage and automated backups
   - Performance insights and enhanced monitoring

4. **Content Delivery**
   - CloudFront distribution for global content delivery
   - WAF integration for security
   - Route 53 for DNS management and failover routing
   - SSL/TLS encryption for all endpoints

5. **Monitoring & Operations**
   - CloudWatch dashboards and alarms
   - SNS notifications for critical events
   - AWS Backup for automated backups
   - Cost management and budgeting

## Prerequisites

- AWS Account with appropriate permissions
- Terraform >= 1.0.0
- AWS CLI configured with appropriate credentials
- S3 bucket for Terraform state (specified in backend configuration)
- DynamoDB table for state locking

## Repository Structure

```
.
├── infrastructure/
│   └── terraform/
│       ├── modules/
│       │   ├── application/    # Application layer configuration
│       │   ├── cdn/           # CloudFront and Route 53 configuration
│       │   ├── database/      # Aurora Global Database configuration
│       │   ├── monitoring/    # Monitoring and backup configuration
│       │   └── vpc/          # Network infrastructure
│       ├── main.tf           # Main Terraform configuration
│       ├── variables.tf      # Input variables
│       └── outputs.tf        # Output values
└── src/                     # Application source code
```

## Module Documentation

### VPC Module
The VPC module (`modules/vpc`) creates the network infrastructure in each region.

**Features:**
- Multi-AZ deployment
- Public and private subnets
- Internet and NAT Gateways
- Route tables and network ACLs

**Usage:**
```hcl
module "vpc_primary" {
  source = "./modules/vpc"
  
  environment     = "prod"
  region         = "us-east-1"
  vpc_cidr       = "10.0.0.0/16"
  azs            = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}
```

### Application Module
The application module (`modules/application`) manages the compute layer.

**Features:**
- Application Load Balancer configuration
- Auto Scaling Groups
- Launch Templates
- Security Groups
- IAM roles and policies

**Usage:**
```hcl
module "application" {
  source = "./modules/application"
  
  environment     = "prod"
  vpc_id         = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnet_ids
  public_subnets  = module.vpc.public_subnet_ids
}
```

### Database Module
The database module (`modules/database`) sets up Aurora Global Database.

**Features:**
- Multi-region database cluster
- Automated failover
- Encryption at rest
- Backup configuration
- Performance monitoring

**Usage:**
```hcl
module "database" {
  source = "./modules/database"
  
  environment      = "prod"
  master_username  = var.db_username
  master_password  = var.db_password
  instance_class   = "db.r6g.large"
}
```

### CDN Module
The CDN module (`modules/cdn`) configures content delivery and DNS.

**Features:**
- CloudFront distribution
- WAF rules and security
- Route 53 DNS management
- SSL/TLS certificate management

**Usage:**
```hcl
module "cdn" {
  source = "./modules/cdn"
  
  environment        = "prod"
  domain_name       = "example.com"
  primary_alb_dns   = module.application.alb_dns_name
  secondary_alb_dns = module.application_secondary.alb_dns_name
}
```

### Monitoring Module
The monitoring module (`modules/monitoring`) sets up observability and backup.

**Features:**
- CloudWatch dashboards
- SNS notifications
- AWS Backup configuration
- Cost management

**Usage:**
```hcl
module "monitoring" {
  source = "./modules/monitoring"
  
  environment     = "prod"
  primary_region  = "us-east-1"
  secondary_region = "us-west-2"
}
```

## Deployment

1. Initialize Terraform:
```bash
terraform init
```

2. Review the plan:
```bash
terraform plan -var-file=prod.tfvars
```

3. Apply the configuration:
```bash
terraform apply -var-file=prod.tfvars
```

## Security Considerations

- All data is encrypted at rest and in transit
- Network isolation through VPC design
- WAF rules for application protection
- IAM roles follow principle of least privilege
- Regular security patches through automated updates
- Compliance monitoring through AWS Config

## Monitoring and Maintenance

- CloudWatch dashboards for infrastructure metrics
- Automated alerts for critical events
- Daily backups with 30-day retention
- Cost monitoring and budget alerts
- Performance metrics and insights

## Disaster Recovery

The infrastructure supports the following disaster recovery scenarios:

1. **Region Failure**
   - Automated failover to secondary region
   - Route 53 health checks trigger DNS updates
   - Aurora Global Database handles data replication

2. **Availability Zone Failure**
   - Auto Scaling Groups span multiple AZs
   - Load balancers automatically route traffic
   - No manual intervention required

3. **Instance Failure**
   - Health checks detect failed instances
   - Auto Scaling Groups replace unhealthy instances
   - Load balancers route traffic to healthy instances

## Cost Management

- Resource tagging for cost allocation
- Budget alerts prevent overspending
- Auto Scaling optimizes resource usage
- Reserved Instances recommended for stable workloads

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.