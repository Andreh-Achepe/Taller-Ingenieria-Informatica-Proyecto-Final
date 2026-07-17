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


resource "aws_lambda_permission" "booking_alb" {
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_booking.lambda_function_name
  principal     = "elasticloadbalancing.amazonaws.com"
}

resource "aws_lb_target_group_attachment" "booking" {
  depends_on       = [aws_lambda_permission.booking_alb]
  target_group_arn = module.alb.target_groups["booking-lambda"].arn
  target_id        = module.lambda_booking.lambda_function_arn
}

module "lambda_testimonios" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 8.8.0"

  function_name = "${lower(var.project)}-testimonios"
  description   = "Gestiona testimonios de clientes"
  handler       = "testimonios.handler"
  runtime       = var.lambda_runtime
  source_path   = "${path.module}/lambda"

  create_lambda_function_url = true
  authorization_type         = "NONE"
  cors = {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "PUT", "DELETE"]
    allow_headers = ["Content-Type"]
  }

  environment_variables = {
    BUCKET_NAME = module.s3-bucket.s3_bucket_id
  }

  attach_policy_statements = true
  policy_statements = {
    s3 = {
      effect  = "Allow"
      actions = ["s3:PutObject", "s3:GetObject", "s3:ListBucket", "s3:DeleteObject"]
      resources = [
        module.s3-bucket.s3_bucket_arn,
        "${module.s3-bucket.s3_bucket_arn}/*"
      ]
    }
  }

  tags = var.tags
}

resource "aws_lambda_permission" "testimonios_alb" {
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_testimonios.lambda_function_name
  principal     = "elasticloadbalancing.amazonaws.com"
}

resource "aws_lb_target_group_attachment" "testimonios" {
  depends_on       = [aws_lambda_permission.testimonios_alb]
  target_group_arn = module.alb.target_groups["testimonios-lambda"].arn
  target_id        = module.lambda_testimonios.lambda_function_arn
}

module "lambda_lugares" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 8.8.0"

  function_name = "${lower(var.project)}-lugares"
  description   = "Gestiona lugares para mostrar recorridos"
  handler       = "lugares.handler"
  runtime       = var.lambda_runtime
  source_path   = "${path.module}/lambda"

  environment_variables = {
    TABLE_NAME  = module.dynamodb-table.dynamodb_table_id
    BUCKET_NAME = module.s3-bucket.s3_bucket_id
  }
  # en la presentacion recalcamos que las policies se crean aca mismo
  # mas que nada para no webiar tanto con el IAM y tener todo en su lugar
  # Ademmas es mas legible, la desicion no es arquitecntonica, es de trabajo y lectura
  attach_policy_statements = true
  policy_statements = {
    dynamodb_lugares = {
      effect = "Allow"
      actions = [
        "dynamodb:PutItem",
        "dynamodb:GetItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem",
        "dynamodb:Scan"
      ]
      resources = [
        module.dynamodb-table.dynamodb_table_arn,
        "${module.dynamodb-table.dynamodb_table_arn}/index/*"
      ]
    },
    s3 = {
      effect    = "Allow"
      actions   = ["s3:PutObject", "s3:GetObject"]
      resources = ["${module.s3-bucket.s3_bucket_arn}/*"]
    }
  }
  tags = var.tags
}

resource "aws_lambda_permission" "lugares_alb" {
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_lugares.lambda_function_name
  principal     = "elasticloadbalancing.amazonaws.com"
}

resource "aws_lb_target_group_attachment" "lugares" {
  depends_on       = [aws_lambda_permission.lugares_alb]
  target_group_arn = module.alb.target_groups["lugares-lambda"].arn
  target_id        = module.lambda_lugares.lambda_function_arn
}
