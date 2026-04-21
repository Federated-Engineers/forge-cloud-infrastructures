# Balearic Blue Superyacht Services (BBSS) Infra

module "bbss_weather_bucket" {
  source = "../modules/s3-bucket"

  environment     = var.environment
  team            = "forge"
  bucket-use-case = "bbss-forecasts"
  service         = "airflow"
  versioning      = "Enabled"
}

