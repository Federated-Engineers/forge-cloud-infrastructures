locals {
  common_tags = {
    environment = var.environment
    team        = var.team
    terraform   = true
  }
}
