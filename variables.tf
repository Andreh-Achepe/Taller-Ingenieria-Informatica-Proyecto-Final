variable "project" {
  type        = string
  description = "Project name"
  default     = "ulagos-fdici12"
}
variable "region" {
  type        = string
  description = "Region of the project"
}

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



