terraform {
  required_version = ">= 1.0.0"
  
  backend "s3" {
    # Configure your S3 backend
    bucket         = "your-terraform-state-bucket"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.primary_region
  alias  = "primary"
}

provider "aws" {
  region = var.secondary_region
  alias  = "secondary"
}

# VPC Module for Primary Region
module "vpc_primary" {
  source = "./modules/vpc"
  providers = {
    aws = aws.primary
  }

  environment     = var.environment
  region         = var.primary_region
  vpc_cidr       = var.primary_vpc_cidr
  azs            = var.primary_azs
  private_subnets = var.primary_private_subnets
  public_subnets  = var.primary_public_subnets

  tags = local.common_tags
}

# VPC Module for Secondary Region
module "vpc_secondary" {
  source = "./modules/vpc"
  providers = {
    aws = aws.secondary
  }

  environment     = var.environment
  region         = var.secondary_region
  vpc_cidr       = var.secondary_vpc_cidr
  azs            = var.secondary_azs
  private_subnets = var.secondary_private_subnets
  public_subnets  = var.secondary_public_subnets

  tags = local.common_tags
}