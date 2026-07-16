module "s3_staging_bucket" {
  source          = "../modules/s3_bucket"
  team            = var.team
  bucket-use-case = "data-lake"
  service         = "s3"
  versioning      = "Enabled"
  environment     = var.environment
}
