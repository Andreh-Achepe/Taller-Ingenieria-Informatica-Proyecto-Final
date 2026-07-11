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
  }

  tags = var.tags
}
