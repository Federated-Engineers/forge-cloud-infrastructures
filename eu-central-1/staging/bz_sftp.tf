# Bieler Zeitwerk SFTP Infrastructure

module "bz_sftp_bucket" {
  source = "../modules/s3-bucket"

  environment     = var.environment
  team            = var.team
  bucket-use-case = "sftp"
  service         = "transfer-family"
  versioning      = "Enabled"
}

