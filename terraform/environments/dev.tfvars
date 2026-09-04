# Development Environment Variables (AWS Dev Profile - Cost & Resource Optimized)
aws_region          = "us-east-1"
environment         = "dev"
cluster_name        = "robotshop"
k8s_version         = "1.32"
vpc_cidr            = "10.10.0.0/16"
node_instance_types = ["t3.medium"]
desired_nodes       = 2
max_nodes           = 3
min_nodes           = 1
capacity_type       = "ON_DEMAND"
enable_ecs          = false
