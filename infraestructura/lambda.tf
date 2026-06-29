module "lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 8.8.0"

  function_name = "${lower(var.project)}-function"
  description   = "Lambda para subir archivos a S3 y guardar referencia en DynamoDB"
  handler       = "index.handler"
  runtime       = "python3.12"
  source_path   = "${path.module}/lambda"

  environment_variables = {
    TABLE_NAME  = module.dynamodb-table.dynamodb_table_id
    BUCKET_NAME = module.s3-bucket.s3_bucket_id
  }

  attach_policy_statements = true
  policy_statements = {
    dynamodb = {
      effect = "Allow"
      actions = [
        "dynamodb:PutItem",
        "dynamodb:GetItem",
        "dynamodb:Query"
      ]
      resources = [
        module.dynamodb-table.dynamodb_table_arn,
        "${module.dynamodb-table.dynamodb_table_arn}/index/*"
      ]
    }
    s3 = {
      effect = "Allow"
      actions = [
        "s3:PutObject",
        "s3:GetObject"
      ]
      resources = [
        "${module.s3-bucket.s3_bucket_arn}/*"
      ]
    }
  }

  tags = var.tags
}
