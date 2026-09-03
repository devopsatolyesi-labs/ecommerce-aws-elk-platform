variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "cluster_name" {
  type        = string
  description = "Base cluster name"
}

variable "environment" {
  type        = string
  description = "Target environment (dev, staging, prod)"
}
