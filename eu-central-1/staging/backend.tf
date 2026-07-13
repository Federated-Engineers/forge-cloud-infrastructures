terraform {
  backend "s3" {
    bucket = "federated-engineers-forge-team-staging"
    key    = "staging/forge/terraform.tfstate"
    region = "eu-central-1"
  }
}
