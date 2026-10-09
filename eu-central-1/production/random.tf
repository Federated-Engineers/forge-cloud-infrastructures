resource "random_string" "spreekauf_password" {
  length  = 16
  count   = 1
  special = false
  upper   = false
}


