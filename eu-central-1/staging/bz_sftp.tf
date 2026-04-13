# =============================================================
# Bieler Zeitwerk SFTP Infrastructure
# =============================================================
# Resources:
#   S3 bucket — dedicated SFTP file exchange bucket
#   CloudWatch — SFTP audit log group
#   IAM role — Transfer Family, s3 and CloudWatch (logging)
#   Transfer Server — AWS Transfer Family SFTP server
#   Transfer User — bz-repair partner
#   SSH Key — partner's public key for authentication
# =============================================================


# -------------------------------------------------------------
# S3 BUCKET — Dedicated SFTP file exchange
# -------------------------------------------------------------
module "bz_sftp_bucket" {
  source = "../modules/s3-bucket"

  environment     = var.environment
  team            = var.team
  bucket-use-case = "sftp"
  service         = "transfer-family"
  versioning      = "Enabled"
}
