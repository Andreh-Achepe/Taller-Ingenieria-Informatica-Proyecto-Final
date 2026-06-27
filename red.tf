module "net_conecctons" {
  # datos base de modulo
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.6.1"

  # info de modulo
  name            = var.vpc_name
  cidr            = var.vpc_cidr
  azs             = var.availability_zones
  public_subnets  = var.vpc_public_subnets
  private_subnets = var.vpc_private_subnets


  enable_nat_gateway = true
  # Esto permite alta disponibilidad
  one_nat_gateway_per_az = true
  single_nat_gateway     = false
  enable_dns_hostnames   = true
  tags = {
    Terraform = "true"
  }
}
