# Staging Environment Variables
aws_region          = "us-east-1"
environment         = "staging"
cluster_name        = "robotshop"
k8s_version         = "1.32"
vpc_cidr            = "10.20.0.0/16"
node_instance_types = ["t3.medium"]
desired_nodes       = 2
max_nodes           = 4
min_nodes           = 1
capacity_type       = "ON_DEMAND"
enable_ecs          = false
