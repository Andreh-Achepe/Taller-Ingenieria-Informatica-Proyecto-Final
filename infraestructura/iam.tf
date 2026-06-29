module "iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 6.6.1"

  name        = "${var.project}-policy"
  path        = "/"
  description = "Oernusis para ejecucion de ECS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = "*"
    }]
  })

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role"
  version = "~> 6.6.1"

  name = "${var.project}-IAM-role"

  trust_policy_permissions = {
    ecstasks = {
      actions = ["sts:AssumeRole"]
      principals = [{
        type        = "Service"
        identifiers = ["ecs-tasks.amazonaws.com"]
      }]
    }
  }

  policies = {
    ecs_execution = module.iam_policy.arn
  }

  tags = {
    Terraform = "true"
    Project   = var.project
  }
}
