module "forge_data_lake" {
  source = "../modules/s3-bucket"

  environment     = var.environment
  team            = var.team
  bucket-use-case = "datalake"
  service         = "airflow"
  versioning      = var.versioning
}

# Balearic Blue Superyacht Services (BBSS) Infra
module "bbss_weather_bucket" {
  source = "../modules/s3-bucket"

  environment     = var.environment
  team            = var.team
  bucket-use-case = "bbss-forecasts"
  service         = "airflow"
  versioning      = var.versioning

}
