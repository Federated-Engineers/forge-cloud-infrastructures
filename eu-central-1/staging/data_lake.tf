module "forge-data-engineers-staging-bucket" {
  source          = "../modules/s3_bucket"
  team            = var.team
  bucket-use-case = "data-engineers-bucket"
  service         = "s3"
  versioning      = "Disabled"
  environment     = var.environment
}
