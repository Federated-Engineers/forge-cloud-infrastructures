resource "random_string" "spreekauf_password" {
  length  = 16
  count   = 1
  special = true
  upper   = true
}


