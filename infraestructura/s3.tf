module "s3-bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 5.14.1"
  # No puedo creer que exista la funcion lower la verdad
  bucket        = "${lower(var.project)}-bucket-${var.region}"
  force_destroy = true

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
  tags = var.tags
}

module "s3-bucket_notification" {
  source  = "terraform-aws-modules/s3-bucket/aws//modules/notification"
  version = "~> 5.14.1"

  bucket     = module.s3-bucket.s3_bucket_id
  bucket_arn = module.s3-bucket.s3_bucket_arn


  lambda_notifications = {
    s3_to_lambda = {
      function_arn  = module.lambda.lambda_function_arn
      function_name = module.lambda.lambda_function_name
      events        = ["s3:ObjectCreated:*"]
    }
  }

}
