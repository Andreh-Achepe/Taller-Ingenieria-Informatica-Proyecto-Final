terraform {
  backend "s3" {
    # bucket       = "bucket-de-475554724337para-terrafor-aigues-1782536366"
    # key          = "terraform.tfstate"
    # region       = "us-east-1"

    use_lockfile = true
    # dynamodb_table = "GuardadoTerraform"
    # terraform dice que ya no es necesario dynamodb para bloquear el estado
    encrypt = true
  }
}
