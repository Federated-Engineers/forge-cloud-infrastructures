module "glaciair_sync_bucket" {
  source = "../modules/s3-bucket"

  team            = "forge"
  environment     = var.environment
  bucket-use-case = "glaci-air-data-lake"
  service         = "airflow"
  versioning      = "Enabled"
}
