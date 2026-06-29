module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 7.5.0"

  cluster_name = "${var.project}-CLUSTER"

  cluster_capacity_providers = ["FARGATE"]
  services = {
    web = {
      family                   = "${var.project}-service-cluster"
      network_mode             = "awsvpc"
      requires_compatibilities = ["FARGATE"]
      cpu                      = var.service_cpu
      memory                   = var.service_memory
      # Impedimos errores al poner esta cuestion, basicamente le decimos que pondremos el rol fabricado por nosotros
      create_tasks_iam_role  = false
      task_exec_iam_role_arn = module.iam_role.arn

      container_definitions = {
        web = {
          name  = "${var.project}-contenedor-cluster"
          image = nonsensitive(var.ecr_image_uri)
          portMappings = [{
            containerPort = var.container_port
          }]
          readonlyRootFilesystem                 = false
          enable_cloudwatch_logging              = var.cloudwatch_loggin
          create_cloudwatch_log_group            = true
          cloudwatch_log_group_retention_in_days = var.log_retention_days
        }
      }

      name          = "${var.project}-service"
      desired_count = var.service_desired_count
      launch_type   = "FARGATE"

      subnet_ids         = module.net_connections.private_subnets
      security_group_ids = [module.security_group_priv.id]
      assign_public_ip   = false

      load_balancer = {
        web = {
          target_group_arn = module.alb.target_groups["web-fargate"].arn
          container_name   = "${var.project}-contenedor-cluster"
          container_port   = 80
        }
      }
      wait_for_steady_state = true
    }
  }
  tags = var.tags
}

