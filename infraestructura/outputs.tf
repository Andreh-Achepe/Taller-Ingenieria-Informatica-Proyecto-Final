output "vpc_id" {
  description = "ID of the VPC"
  value       = module.net_connections.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.net_connections.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "ID of public subnet"
  value       = module.net_connections.public_subnets
}

output "private_subnets_ids" {
  value       = module.net_connections.private_subnets
  description = "IDs of private subnets"
}

# SECURITY GROUPS

output "alb_security_group_id" {
  value       = module.security_group_alb.id
  description = "Security group ID for ALB"
}

output "ecs_security_group_id" {
  value       = module.security_group_priv.id
  description = "Security group ID for ECS containers"
}

# ALB
output "alb_arn" {
  value       = module.alb.arn
  description = "ARN of the application load balancer"
}

output "alb_target_group_arns" {
  description = "ARNs of the ALB target groups"
  # Esto me lo dio la IA directamente
  # Entiendo que simplemente itera sobre pares clave:valor para obtener todos los arn (1)
  value = { for k, v in module.alb.target_groups : k => v.arn }
}


output "alb_dns" {
  description = "DNS for the task"
  value       = module.alb.dns_name
}

# ECS

output "cluster_id" {
  description = "Cluster ID"
  value       = module.ecs.cluster_id
}

output "service_name" {
  description = "Local name of the service in the cluster"
  value       = module.ecs.services["web"].name
}

output "ecs_cluster_arn" {
  value       = module.ecs.cluster_arn
  description = "Cluster ARN"
}

output "ecs_service_arn" {
  value       = module.ecs.services["web"].id
  description = "ARN of ECS service"
}

# IAM

output "ecs_task_role_arn" {
  description = "ARN of the IAM role for ECS tasks"
  value       = module.iam_role.arn
}

output "ecs_task_role_name" {
  description = "Name of the IAM role for ECS tasks"
  value       = module.iam_role.name
}

output "ecs_execution_policy_arn" {
  description = "ARN of the IAM policy for ECS execution"
  value       = module.iam_policy.arn
}
# S3
output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = module.s3-bucket.s3_bucket_id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = module.s3-bucket.s3_bucket_arn
}


# DynamoDB

output "dynamodb_table_name" {
  value       = module.dynamodb-table.dynamodb_table_id
  description = "Name of dynamodb table"
}

output "dynamodb-table_arn" {
  value       = module.dynamodb-table.dynamodb_table_arn
  description = "ARN of dynamoDB table"
}

# lambda function

output "lambda_function_name" {
  value       = module.lambda.lambda_function_name
  description = "Name of lamdba"
}

output "lambda_function_arn" {
  value       = module.lambda.lambda_function_arn
  description = "Arn of lambda function"
}
