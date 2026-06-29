module "dynamodb-table" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "~> 5.5.0"

  name     = lower(var.project)
  hash_key = "id"

  attributes = [
    { name = "id", type = "N" },
    { name = "ramo", type = "S" }
  ]

  global_secondary_indexes = [{
    name            = "ramo-index"
    hash_key        = "ramo"
    projection_type = "ALL"
  }]

  tags = var.tags
}
