# ==============================================================================
# AWS ECR Module: Secure Container Registries with Vulnerability Scanning
# ==============================================================================

variable "repository_names" {
  type        = list(string)
  description = "List of ECR repository names"
  default = [
    "robotshop/web",
    "robotshop/catalogue",
    "robotshop/cart",
    "robotshop/user",
    "robotshop/payment",
    "robotshop/shipping",
    "robotshop/dispatch",
    "robotshop/ratings"
  ]
}

variable "environment" {
  type = string
}

resource "aws_ecr_repository" "this" {
  for_each             = toset(var.repository_names)
  name                 = each.key
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Environment = var.environment
  }
}

# Lifecycle policy to retain only recent 10 images (Cost Optimization)
resource "aws_ecr_lifecycle_policy" "this" {
  for_each   = toset(var.repository_names)
  repository = aws_ecr_repository.this[each.key].name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 10 images"
      selection = {
        tagStatus   = "any"
        countType   = "sinceImagePushed"
        countUnit   = "days"
        countNumber = 30
      }
      action = { type = "expire" }
    }]
  })
}

output "repository_urls" {
  value       = { for k, v in aws_ecr_repository.this : k => v.repository_url }
  description = "Map of repository names to ECR repository URLs"
}
