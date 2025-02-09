# =============================================================================
# Infrastructure Deployment Makefile
# 
# This Makefile automates the deployment and management of AWS infrastructure
# using Terraform. It provides targets for initialization, planning, applying,
# and maintaining infrastructure across different environments.
# =============================================================================

# -----------------------------------------------------------------------------
# Environment Configuration
# These variables can be overridden using environment variables or command line
# Example: ENV=prod make plan
# -----------------------------------------------------------------------------
ENV ?= dev                                    # Default environment
TERRAFORM_DIR = infrastructure/terraform      # Terraform files location
STATE_BUCKET ?= your-terraform-state-bucket   # S3 bucket for Terraform state
DYNAMODB_TABLE ?= terraform-state-lock       # DynamoDB table for state locking
AWS_REGION ?= us-east-1                      # Default AWS region
WORKSPACE ?= $(ENV)                          # Terraform workspace name

# -----------------------------------------------------------------------------
# Output Formatting
# ANSI color codes for better readability of command output
# -----------------------------------------------------------------------------
GREEN := \033[0;32m
RED := \033[0;31m
YELLOW := \033[0;33m
NC := \033[0m # No Color

# -----------------------------------------------------------------------------
# Phony Targets
# Declares all targets that don't represent files
# -----------------------------------------------------------------------------
.PHONY: help init plan apply destroy validate clean format test backup import refresh

# -----------------------------------------------------------------------------
# Help Target
# Displays available targets and their descriptions
# Usage: make help
# -----------------------------------------------------------------------------
help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo
	@echo 'Targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'

# -----------------------------------------------------------------------------
# Environment Validation
# Ensures ENV variable is set before running commands
# -----------------------------------------------------------------------------
check-env:
	@if [ "$(ENV)" = "" ]; then \
		echo "$(RED)ENV is not set. Use ENV=<environment_name> make <target>$(NC)"; \
		exit 1; \
	fi

# -----------------------------------------------------------------------------
# Core Terraform Operations
# Basic operations for managing infrastructure
# -----------------------------------------------------------------------------

# Initialize Terraform and configure backend
# Usage: make init ENV=<environment>
init: check-env ## Initialize Terraform working directory
	@echo "$(YELLOW)Initializing Terraform...$(NC)"
	@cd $(TERRAFORM_DIR) && \
	terraform init \
		-backend-config="bucket=$(STATE_BUCKET)" \
		-backend-config="key=$(ENV)/terraform.tfstate" \
		-backend-config="region=$(AWS_REGION)" \
		-backend-config="dynamodb_table=$(DYNAMODB_TABLE)"

# Create or switch to a Terraform workspace
# Usage: make workspace ENV=<environment>
workspace: init ## Create and switch to a Terraform workspace
	@echo "$(YELLOW)Setting up workspace $(WORKSPACE)...$(NC)"
	@cd $(TERRAFORM_DIR) && \
	terraform workspace select $(WORKSPACE) 2>/dev/null || terraform workspace new $(WORKSPACE)

# Create an execution plan
# Usage: make plan ENV=<environment>
plan: workspace ## Create a Terraform plan
	@echo "$(YELLOW)Creating Terraform plan...$(NC)"
	@cd $(TERRAFORM_DIR) && \
	terraform plan -var-file="$(ENV).tfvars" -out=tfplan

# Apply the Terraform plan
# Usage: make apply ENV=<environment>
apply: workspace ## Apply Terraform plan
	@echo "$(YELLOW)Applying Terraform plan...$(NC)"
	@cd $(TERRAFORM_DIR) && \
	terraform apply tfplan

# Destroy infrastructure
# Usage: make destroy ENV=<environment>
destroy: workspace ## Destroy Terraform-managed infrastructure
	@echo "$(RED)WARNING: This will destroy all resources in $(ENV) environment!$(NC)"
	@read -p "Are you sure? [y/N]: " confirm && \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		cd $(TERRAFORM_DIR) && \
		terraform destroy -var-file="$(ENV).tfvars" -auto-approve; \
	fi

# -----------------------------------------------------------------------------
# Validation and Formatting
# Code quality and formatting operations
# -----------------------------------------------------------------------------

# Validate Terraform configurations
# Usage: make validate
validate: ## Validate Terraform files
	@echo "$(YELLOW)Validating Terraform files...$(NC)"
	@cd $(TERRAFORM_DIR) && \
	terraform fmt -check && \
	terraform validate

# Format Terraform files
# Usage: make format
format: ## Format Terraform files
	@echo "$(YELLOW)Formatting Terraform files...$(NC)"
	@cd $(TERRAFORM_DIR) && \
	terraform fmt -recursive

# Run infrastructure tests
# Usage: make test
test: ## Run infrastructure tests
	@echo "$(YELLOW)Running tests...$(NC)"
	@cd $(TERRAFORM_DIR) && \
	terraform test

# -----------------------------------------------------------------------------
# State Management
# Operations for managing Terraform state
# -----------------------------------------------------------------------------

# Clean up Terraform files
# Usage: make clean
clean: ## Clean up Terraform files
	@echo "$(YELLOW)Cleaning up...$(NC)"
	@cd $(TERRAFORM_DIR) && \
	rm -rf .terraform/ tfplan .terraform.lock.hcl

# Create state backup
# Usage: make backup ENV=<environment>
backup: check-env ## Create manual backup of state
	@echo "$(YELLOW)Creating state backup...$(NC)"
	@cd $(TERRAFORM_DIR) && \
	terraform state pull > "../backups/terraform-$(ENV)-$(shell date +%Y%m%d-%H%M%S).tfstate"

# Import existing infrastructure
# Usage: make import ENV=<environment> ADDRESS=<resource_address> ID=<resource_id>
import: workspace ## Import existing infrastructure into Terraform state
	@if [ "$(ADDRESS)" = "" ] || [ "$(ID)" = "" ]; then \
		echo "$(RED)Usage: make import ADDRESS=<resource_address> ID=<resource_id>$(NC)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)Importing $(ID) into $(ADDRESS)...$(NC)"
	@cd $(TERRAFORM_DIR) && \
	terraform import -var-file="$(ENV).tfvars" $(ADDRESS) $(ID)

# Refresh Terraform state
# Usage: make refresh ENV=<environment>
refresh: workspace ## Refresh Terraform state
	@echo "$(YELLOW)Refreshing Terraform state...$(NC)"
	@cd $(TERRAFORM_DIR) && \
	terraform refresh -var-file="$(ENV).tfvars"

# -----------------------------------------------------------------------------
# Maintenance Tasks
# Regular maintenance and update operations
# -----------------------------------------------------------------------------

# Update provider versions
# Usage: make update-providers
update-providers: init ## Update provider versions
	@echo "$(YELLOW)Updating provider versions...$(NC)"
	@cd $(TERRAFORM_DIR) && \
	terraform init -upgrade

# Estimate infrastructure costs
# Usage: make cost-estimate ENV=<environment>
cost-estimate: workspace ## Estimate infrastructure costs
	@echo "$(YELLOW)Generating cost estimate...$(NC)"
	@cd $(TERRAFORM_DIR) && \
	terraform plan -var-file="$(ENV).tfvars" -out=tfplan && \
	terraform show -json tfplan | jq -r '.resource_changes[] | select(.change.actions[] | contains("create", "update")) | .address + ": " + .change.actions[]'

# Run security scan
# Usage: make security-scan
security-scan: ## Run security scan on Terraform code
	@echo "$(YELLOW)Running security scan...$(NC)"
	@if command -v tfsec >/dev/null 2>&1; then \
		cd $(TERRAFORM_DIR) && \
		tfsec .; \
	else \
		echo "$(RED)tfsec is not installed. Please install it first.$(NC)"; \
		exit 1; \
	fi

# Generate documentation
# Usage: make docs
docs: ## Generate Terraform documentation
	@echo "$(YELLOW)Generating documentation...$(NC)"
	@if command -v terraform-docs >/dev/null 2>&1; then \
		cd $(TERRAFORM_DIR) && \
		terraform-docs markdown . > docs/terraform.md; \
	else \
		echo "$(RED)terraform-docs is not installed. Please install it first.$(NC)"; \
		exit 1; \
	fi

# -----------------------------------------------------------------------------
# Development Environment Setup
# Initial setup and configuration for development
# -----------------------------------------------------------------------------

# Set up development environment
# Usage: make dev-env ENV=<environment>
dev-env: ## Set up development environment
	@echo "$(YELLOW)Setting up development environment...$(NC)"
	@if [ ! -f ".env.$(ENV)" ]; then \
		echo "Creating .env.$(ENV) file..."; \
		echo "AWS_REGION=$(AWS_REGION)" > .env.$(ENV); \
		echo "STATE_BUCKET=$(STATE_BUCKET)" >> .env.$(ENV); \
		echo "DYNAMODB_TABLE=$(DYNAMODB_TABLE)" >> .env.$(ENV); \
	fi