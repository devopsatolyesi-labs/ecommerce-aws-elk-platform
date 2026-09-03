output "cluster_name" {
  value       = module.eks.cluster_name
  description = "EKS Cluster Name"
}

output "cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "EKS Cluster API Endpoint"
}

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "Provisioned VPC ID"
}

output "public_subnets" {
  value       = module.vpc.public_subnets
  description = "Public Subnet IDs"
}

output "private_subnets" {
  value       = module.vpc.private_subnets
  description = "Private Subnet IDs"
}

output "kubeconfig_command" {
  value       = "aws eks --region ${var.aws_region} update-kubeconfig --name ${module.eks.cluster_name}"
  description = "CLI command to configure kubectl credentials for the EKS cluster"
}

output "ecr_repositories" {
  value       = module.ecr.repository_urls
  description = "Map of microservice names to ECR repository URLs"
}

output "ecs_cluster_name" {
  value       = var.enable_ecs ? module.ecs[0].cluster_name : "Disabled"
  description = "ECS Cluster Name"
}
