variable "environment" {
  description = "Environment name"
  type        = string
}

variable "primary_vpc_id" {
  description = "VPC ID in primary region"
  type        = string
}

variable "secondary_vpc_id" {
  description = "VPC ID in secondary region"
  type        = string
}

variable "primary_subnet_ids" {
  description = "List of subnet IDs in primary region"
  type        = list(string)
}

variable "secondary_subnet_ids" {
  description = "List of subnet IDs in secondary region"
  type        = list(string)
}

variable "primary_app_security_group_ids" {
  description = "List of application security group IDs in primary region"
  type        = list(string)
}

variable "secondary_app_security_group_ids" {
  description = "List of application security group IDs in secondary region"
  type        = list(string)
}

variable "master_username" {
  description = "Master username for the database"
  type        = string
  sensitive   = true
}

variable "master_password" {
  description = "Master password for the database"
  type        = string
  sensitive   = true
}

variable "instance_class" {
  description = "Instance class for database instances"
  type        = string
  default     = "db.r6g.large"
}

variable "primary_instance_count" {
  description = "Number of database instances in primary region"
  type        = number
  default     = 2
}

variable "secondary_instance_count" {
  description = "Number of database instances in secondary region"
  type        = number
  default     = 2
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}