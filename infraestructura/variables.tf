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
}

# VPC
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
