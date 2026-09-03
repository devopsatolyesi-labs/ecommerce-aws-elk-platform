# ==============================================================================
# Modular Multi-Environment Terraform Root
# Supports dev, staging, and production via -var-file and separate tfstates
# ==============================================================================

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "ecommerce-platform"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = "DevOps-Atolyesi"
    }
  }
}

# 1. Reusable VPC Module
module "vpc" {
  source       = "./modules/vpc"
  vpc_cidr     = var.vpc_cidr
  cluster_name = var.cluster_name
  environment  = var.environment
}

# 2. Reusable EKS Module
module "eks" {
  source             = "./modules/eks"
  cluster_name       = var.cluster_name
  environment        = var.environment
  k8s_version        = var.k8s_version
  subnet_ids         = concat(module.vpc.public_subnets, module.vpc.private_subnets)
  private_subnet_ids = module.vpc.private_subnets
  instance_types     = var.node_instance_types
  desired_nodes      = var.desired_nodes
  max_nodes          = var.max_nodes
  min_nodes          = var.min_nodes
  capacity_type      = var.capacity_type
}
