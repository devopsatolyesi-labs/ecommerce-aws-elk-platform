variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "environment" {
  type        = string
  description = "Deployment environment (dev, staging, prod)"
}

variable "k8s_version" {
  type        = string
  description = "Kubernetes control plane version"
  default     = "1.31"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for EKS control plane"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for worker node group"
}

variable "instance_types" {
  type        = list(string)
  description = "EC2 instance types for node group"
  default     = ["t3.medium"]
}

variable "desired_nodes" {
  type        = number
  description = "Desired number of worker nodes"
  default     = 2
}

variable "max_nodes" {
  type        = number
  description = "Maximum number of worker nodes"
  default     = 3
}

variable "min_nodes" {
  type        = number
  description = "Minimum number of worker nodes"
  default     = 1
}

variable "capacity_type" {
  type        = string
  description = "Capacity type: ON_DEMAND or SPOT"
  default     = "ON_DEMAND"
}
