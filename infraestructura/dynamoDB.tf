module "dynamodb-table" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "~> 5.5.0"

  name     = lower(var.project)
  hash_key = "id"

  attributes = [
    { name = "id", type = "S" },
    { name = "user-mail", type = "S" },
    { name = "tramo", type = "S" },
    { name = "fecha", type = "S" },
    { name = "entity_type", type = "S" },
  ]

  server_side_encryption_enabled     = true
  server_side_encryption_kms_key_arn = null

  global_secondary_indexes = [
    {
      name            = "entity_type-index"
      hash_key        = "entity_type"
      projection_type = "ALL" #sinceramente no se que hace esta flag de aca
    },
    {
      name            = "user-mail-index"
      hash_key        = "user-mail"
      projection_type = "ALL"
    },
    {
      name            = "tramo-index"
      hash_key        = "tramo"
      projection_type = "ALL"
    },
    {
      name            = "fecha-index"
      hash_key        = "fecha"
      projection_type = "ALL"
    }
  ]

  tags = var.tags
}
