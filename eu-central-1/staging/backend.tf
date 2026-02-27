terraform {
  backend "s3" {
    bucket = "federated-engineers-terraform-state"
    key    = "staging/forge/terraform.tfstate"
    region = "eu-central-1"
  }
}
