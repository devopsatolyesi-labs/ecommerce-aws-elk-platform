variable "cluster_name" { type = string }
variable "environment" { type = string }
variable "k8s_version" { type = string; default = "1.31" }
variable "subnet_ids" { type = list(string) }
variable "private_subnet_ids" { type = list(string) }
variable "instance_types" { type = list(string); default = ["t3.medium"] }
variable "desired_nodes" { type = number; default = 2 }
variable "max_nodes" { type = number; default = 3 }
variable "min_nodes" { type = number; default = 1 }
variable "capacity_type" { type = string; default = "ON_DEMAND" }
