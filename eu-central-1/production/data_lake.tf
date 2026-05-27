# Balearic Blue Superyacht Services (BBSS) Infra

module "bbss_weather_bucket" {
  source = "../modules/s3-bucket"

  environment     = var.environment
  team            = "forge"
  bucket-use-case = "bbss-forecasts"
  service         = "airflow"
  versioning      = "Enabled"
}

module "glaciair_sync_bucket" {
  source = "../modules/s3-bucket"

  team            = "forge"
  environment     = var.environment
  bucket-use-case = "glaci-air-data-lake"
  service         = "airflow"
  versioning      = "Enabled"
}

module "cocosurf_tfstate_bucket" {
  source = "../modules/s3-bucket"

  environment     = var.environment
  team            = "forge"
  bucket-use-case = "cocosurf-gear-tf-state"
  service         = "Terraform"
  versioning      = "Enabled"
}


module "cgs_tfstate_bucket" {
  source = "../modules/s3-bucket"

  environment     = var.environment
  team            = "forge"
  bucket-use-case = "cgs-terraform-state"
  service         = "Terraform"
  versioning      = "Enabled"
}

module "cgs_tfstate_bucket" {
  source = "../modules/s3-bucket"

  environment     = var.environment
  team            = "forge"
  bucket-use-case = "cgs-tf-state"
  service         = "Terraform"
  versioning      = "Enabled"
}