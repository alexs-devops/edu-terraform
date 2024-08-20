terraform {
  source = "../1-aws-part"
}

locals {
  db_creds = yamldecode(sops_decrypt_file(("db-creds.yml")))
}

inputs = {
  username = local.db_creds.username
  password = local.db_creds.password
}
