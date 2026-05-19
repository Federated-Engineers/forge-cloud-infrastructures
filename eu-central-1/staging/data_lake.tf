module "forge_data_lake" {
  source = "../modules/s3-bucket"

  environment     = var.environment
  team            = var.team
  bucket-use-case = "datalake"
  service         = "airflow"
  versioning      = var.versioning
}

module "cocosurf_tfstate_bucket" {
  source = "../modules/s3-bucket"

  environment     = var.environment
  team            = "cocosurf-gear"
  bucket-use-case = "terraform-statefile"
  service         = "Terraform"
  versioning      = var.versioning
}

