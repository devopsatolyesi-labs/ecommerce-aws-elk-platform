variable "cluster_name" {
  type        = string
  description = "Base cluster name"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod)"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where ECS tasks operate"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for ECS tasks"
}
