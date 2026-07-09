# GENERAL

variable "project" {
  type        = string
  description = "Project name"
  default     = "ulagos-fdici12"
}
variable "region" {
  type        = string
  description = "Region of the project"
  default     = "us-east-1"
}


variable "tags" {
  type        = map(string)
  description = "List of tag to make easier the job of identify the resources of the project"
  default = {
    "Project"    = "ULAGOS-TIN-LAB3"
    "Terraform"  = "True"
    "Enviroment" = "Dev"
  }
}

# network
variable "vpc_cidr" {
  type        = string
  description = "Range of local IP of the VPC"
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability_zones"
  default     = ["us-east-1a", "us-east-1b"]
}

variable "vpc_public_subnets" {
  type        = list(string)
  description = "List of all public subnets that we will need"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "vpc_private_subnets" {
  type        = list(string)
  description = "List of all private subnets that probably we will need"
  default     = ["10.0.100.0/24", "10.0.200.0/24"]
}

variable "enable_nat_gateway" {
  type        = bool
  description = "True/False for nat gateway"
  default     = true
}

variable "single_nat_gateway" {
  type        = bool
  description = "For one single internet gateway"
  default     = true
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "Allow the use of DNS"
  default     = true
}

variable "enable_dns_support" {
  type        = bool
  description = "Allow dns support"

}

#  ECS
variable "ecr_image_uri" {
  type        = string
  description = "URI for the Docker image"
  sensitive   = true
}

variable "service_cpu" {
  type        = number
  description = "N° of vCPU for ecs services"
  default     = 256
}

variable "service_memory" {
  type        = number
  description = "Ram memory for ecs service"
  default     = 512

}

variable "service_desired_count" {
  type        = number
  description = "Desired number of containers"
  default     = 2
}

variable "container_port" {
  type        = number
  description = "Desired port of the container"
  default     = 80
}

variable "log_retention_days" {
  type        = number
  description = "Number of day that are available logs"
  default     = 30
}

variable "cloudwatch_loggin" {
  type        = bool
  description = "Cloudwatch loggin"
  default     = true
}


# ALB

variable "alb_listener_port" {
  type        = number
  description = "port that the alb should listen"
  default     = 80
}

variable "alb_protocol" {
  type        = string
  description = "Protocol of the ALB"
  default     = "HTTP"
}

variable "health_check_path" {
  type        = string
  description = "Path where the ALB is gonna health check idk"
  default     = "/"
}

variable "enable_deletion_protectoin" {
  type        = bool
  description = "Boolean that let the ALB be destroyed"
  default     = false
}


# Lambda
variable "lambda_runtime" {
  type        = string
  description = "runtime for lambda function"
  default     = "python3.12"
}

variable "ses_domain" {
  type        = string
  description = "Domain name for the mail address"
  default     = "test.com"

}

variable "sender_email" {
  type        = string
  description = "Email remitente para confirmaciones de booking"
}
