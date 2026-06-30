module "net_connections" {
  # datos base de modulo
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.6.1"

  # info de modulo
  name            = "${var.project}-VPC"
  cidr            = var.vpc_cidr
  azs             = var.availability_zones
  public_subnets  = var.vpc_public_subnets
  private_subnets = var.vpc_private_subnets


  enable_nat_gateway     = var.enable_nat_gateway
  one_nat_gateway_per_az = false
  single_nat_gateway     = var.single_nat_gateway
  enable_dns_hostnames   = var.enable_dns_hostnames
  enable_dns_support     = var.enable_dns_support
  tags                   = var.tags
}
module "security_group_alb" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 6.0.0"

  name        = "${var.project}-SG"
  description = "Security group for ${var.project}"
  vpc_id      = module.net_connections.vpc_id

  ingress_rules = {
    http = {
      from_port   = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
      description = "Http open for everyone"
    }
    https = {
      from_port   = 443
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
      description = "HTTPS open for everyone"
    }
  }

  egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  tags = var.tags
}

module "security_group_priv" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 6.0.0"

  name        = "${var.project}-SG-priv"
  description = "Security group for ${var.project} privado"
  vpc_id      = module.net_connections.vpc_id

  ingress_rules = {
    from-alb = {
      ip_protocol                  = "-1"
      referenced_security_group_id = module.security_group_alb.id
      description                  = "For the ALB"
    }
  }

  egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  tags = var.tags
}
