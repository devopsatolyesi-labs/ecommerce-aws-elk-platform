# Production Environment Variables
aws_region          = "us-east-1"
environment         = "prod"
cluster_name        = "robotshop"
k8s_version         = "1.32"
vpc_cidr            = "10.30.0.0/16"
node_instance_types = ["t3.medium"]
desired_nodes       = 3
max_nodes           = 5
min_nodes           = 2
capacity_type       = "ON_DEMAND"
enable_ecs          = false
