module "lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 8.8.0"

  function_name = "${lower(var.project)}-function"
  description   = "Lambda para subir archivos a S3 y guardar referencia en DynamoDB"
  handler       = "index.handler"
  runtime       = var.lambda_runtime
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

module "lambda_booking" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 8.8.0"

  function_name = "${lower(var.project)}-booking"
  description   = "Procesa reservas de buses y envia confirmacion por email"
  handler       = "handler.handler"
  runtime       = var.lambda_runtime
  source_path   = "${path.module}/lambda"


  create_lambda_function_url = true
  authorization_type         = "NONE"
  cors = {
    allow_origins = ["*"]
    allow_methods = ["POST"]
    allow_headers = ["Content-Type"]
  }
  environment_variables = {
    TABLE_NAME   = module.dynamodb-table.dynamodb_table_id
    SENDER_EMAIL = var.sender_email
  }

  attach_policy_statements = true
  policy_statements = {
    dynamodb = {
      effect    = "Allow"
      actions   = ["dynamodb:PutItem"]
      resources = [module.dynamodb-table.dynamodb_table_arn]
    }
    ses = {
      effect    = "Allow"
      actions   = ["ses:SendEmail", "ses:SendRawEmail"]
      resources = ["*"]
    }
  }
  tags = var.tags
}
