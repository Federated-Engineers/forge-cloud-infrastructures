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

# -------------------------------------------------------------
# S3 ENCRYPTION — Objects encrypted at rest
# -------------------------------------------------------------
resource "aws_s3_bucket_server_side_encryption_configuration" "bz_sftp_bucket_encryption" {
  bucket = module.bz_sftp_bucket.bucket_name

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# -------------------------------------------------------------
# S3 PUBLIC ACCESS BLOCK
# -------------------------------------------------------------
resource "aws_s3_bucket_public_access_block" "bz_sftp_bucket_public_access" {
  bucket = module.bz_sftp_bucket.bucket_name

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -------------------------------------------------------------
# S3 LIFECYCLE
# -------------------------------------------------------------
resource "aws_s3_bucket_lifecycle_configuration" "bz_sftp_bucket_lifecycle" {
  bucket = module.bz_sftp_bucket.bucket_name

  rule {
    id     = "bz-sftp-file-retention"
    status = "Enabled"

    filter {}

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    expiration {
      days = 90
    }

    noncurrent_version_expiration {
      noncurrent_days = 7
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 3
    }
  }
}

# -------------------------------------------------------------
# CLOUDWATCH LOG GROUP
# -------------------------------------------------------------
resource "aws_cloudwatch_log_group" "bz_sftp_logs" {
  name              = "/aws/transfer/bz-sftp-${var.environment}"
  retention_in_days = 90

  tags = local.common_tags
}

