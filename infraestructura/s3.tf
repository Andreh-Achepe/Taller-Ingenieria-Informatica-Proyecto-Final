module "s3-bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 5.14.1"
  # No puedo creer que exista la funcion lower la verdad
  bucket = "${lower(var.project)}-bucket-${var.region}"
}
