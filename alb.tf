module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 10.5.0"

  name                       = "${var.project}-ALB"
  vpc_id                     = module.net_connections.vpc_id
  subnets                    = module.net_connections.public_subnets
  enable_deletion_protection = false # 40 minutos sin que funcione destroy por culpa de que el default de este desgraciado es true
  create_security_group      = false
  security_groups            = [module.security_group_alb.id]

  listeners = {
    ex-http = {
      port     = 80
      protocol = "HTTP"
      forward = {
        target_group_key = "web-fargate"
      }
    }
  }

  target_groups = {
    web-fargate = {
      name_prefix       = "web"
      protocol          = "HTTP"
      port              = 80
      target_type       = "ip"
      create_attachment = false
      health_check = {
        path = "/"
      }
    }
  }

  tags = {
    Project   = var.project
    Terraform = "true"
  }
}
