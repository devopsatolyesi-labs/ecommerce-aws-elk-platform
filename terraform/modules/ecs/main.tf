# ==============================================================================
# AWS ECS Fargate Module (Alternative / Hybrid Container Runtime)
# ==============================================================================

resource "aws_ecs_cluster" "this" {
  name = "${var.cluster_name}-${var.environment}-ecs"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name        = "${var.cluster_name}-${var.environment}-ecs"
    Environment = var.environment
  }
}

resource "aws_iam_role" "ecs_execution" {
  name = "${var.cluster_name}-${var.environment}-ecs-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })

  tags = {
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_execution.name
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${var.cluster_name}-${var.environment}"
  retention_in_days = 7

  tags = {
    Environment = var.environment
  }
}
