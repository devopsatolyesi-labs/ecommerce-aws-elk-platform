output "cluster_name" {
  value       = aws_eks_cluster.main.name
  description = "EKS Cluster Name"
}

output "cluster_endpoint" {
  value       = aws_eks_cluster.main.endpoint
  description = "EKS Cluster API Endpoint"
}

output "vpc_id" {
  value       = aws_vpc.main.id
  description = "Provisioned VPC ID"
}

output "kubeconfig_command" {
  value       = "aws eks --region ${var.aws_region} update-kubeconfig --name ${aws_eks_cluster.main.name}"
  description = "CLI command to configure kubectl credentials for the EKS cluster"
}

output "ecs_cluster_name" {
  value       = var.enable_ecs ? aws_ecs_cluster.main[0].name : "Disabled"
  description = "ECS Cluster Name"
}
