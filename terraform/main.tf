# ==============================================================================
# AWS Cloud Infrastructure as Code (Terraform)
# Provisions AWS VPC, EKS Cluster (v1.31) and ECS Fargate Cluster
# ==============================================================================

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project     = "ecommerce-aws-elk-platform"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = "DevOps-Atolyesi"
    }
  }
}
