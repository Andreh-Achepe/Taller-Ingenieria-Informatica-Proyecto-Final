module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 10.5.0"

  name                       = "${var.project}-ALB"
  vpc_id                     = module.net_connections.vpc_id
  subnets                    = module.net_connections.public_subnets
  enable_deletion_protection = var.enable_deletion_protectoin # 40 minutos sin que funcione destroy por culpa de que el default de este desgraciado es true
  create_security_group      = false
  security_groups            = [module.security_group_alb.id]

  listeners = {
    ex-http = {
      port     = var.alb_listener_port
      protocol = var.alb_protocol
      forward = {
        target_group_key = "web-fargate"
      }
      rules = {
        booking = {
          priority = 10
          actions = [{
            forward = {
              target_group_key = "booking-lambda"
            }
          }]
          conditions = [{
            path_pattern = {
              values = ["/api/booking"]
            }
          }]
        }
        testimonios = {
          priority = 20
          actions = [{
            forward = {
              target_group_key = "testimonios-lambda"
            }
          }]
          conditions = [{
            path_pattern = {
              values = ["/api/testimonios*"]
            }
          }]
        }
        lugares = {
          priority = 30
          actions = [{
            forward = {
              target_group_key = "lugares-lambda"
            }
          }]
          conditions = [{
            path_pattern = {
              values = ["/api/lugares*"]
            }
          }]
        }
      }
    }
  }
  target_groups = {
    web-fargate = {
      name_prefix       = "web"
      protocol          = var.alb_protocol
      port              = var.container_port
      target_type       = "ip"
      create_attachment = false
      health_check = {
        path = var.health_check_path
      }
    }
    booking-lambda = {
      name_prefix       = "book"
      target_type       = "lambda"
      create_attachment = false
    }
    testimonios-lambda = {
      name_prefix       = "test"
      target_type       = "lambda"
      create_attachment = false
    }
    lugares-lambda = {
      name_prefix       = "lugars" # Como que hay maximo de caracteres aca (max 6)
      target_type       = "lambda"
      create_attachment = false
    }
  }

  tags = var.tags
}


resource "aws_appautoscaling_target" "ecs" {
  service_namespace  = "ecs"
  max_capacity       = 4
  min_capacity       = 2
  resource_id        = "service/${module.ecs.cluster_name}/${module.ecs.services["web"].name}"
  scalable_dimension = "ecs:service:DesiredCount"
}

resource "aws_appautoscaling_policy" "ecs_cpu" {
  name               = "${var.project}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 70
  }
}
