output "cluster_id" {
  value       = aws_ecs_cluster.this.id
  description = "AWS ECS Cluster ID"
}

output "cluster_name" {
  value       = aws_ecs_cluster.this.name
  description = "AWS ECS Cluster Name"
}

output "execution_role_arn" {
  value       = aws_iam_role.ecs_execution.arn
  description = "ECS Task Execution IAM Role ARN"
}
