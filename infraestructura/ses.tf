
module "ses" {
  source  = "cloudposse/ses/aws"
  version = "~> 0.25.2"

  domain = var.ses_domain


  # Estos valores quedan en false porque los gestionamos por cloudflare
  ses_user_enabled  = false
  ses_group_enabled = false

  verify_dkim   = false
  verify_domain = false

  tags = var.tags

}
