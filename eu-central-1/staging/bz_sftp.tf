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
# DATA SOURCE — Current AWS account identity
# -------------------------------------------------------------
data "aws_caller_identity" "current" {}

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

# -------------------------------------------------------------
# IAM ROLE — CloudWatch Logging
# -------------------------------------------------------------
resource "aws_iam_role" "bz_sftp_logging_role" {
  name = "bz-sftp-logging-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "transfer.amazonaws.com" }
        Action    = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:transfer:${var.region}:${data.aws_caller_identity.current.account_id}:server/*"
          }
        }
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy" "bz_sftp_logging_policy" {
  name = "bz-sftp-logging-policy"
  role = aws_iam_role.bz_sftp_logging_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents"
        ]

        Resource = "${aws_cloudwatch_log_group.bz_sftp_logs.arn}:*"
      }
    ]
  })
}

# -------------------------------------------------------------
# IAM ROLE — transfer family to S3
# -------------------------------------------------------------
resource "aws_iam_role" "bz_sftp_user_role" {
  name = "bz-sftp-user-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "transfer.amazonaws.com" }
        Action    = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:transfer:${var.region}:${data.aws_caller_identity.current.account_id}:server/*"
          }
        }
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy" "bz_sftp_user_s3_policy" {
  name = "bz-sftp-user-s3-policy"
  role = aws_iam_role.bz_sftp_user_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = module.bz_sftp_bucket.arn
        Condition = {
          StringLike = {
            "s3:prefix" = [
              "bieler-zeitwerk/",
              "bieler-zeitwerk/*"
            ]
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Resource = "${module.bz_sftp_bucket.arn}/bieler-zeitwerk/*"
      }
    ]
  })
}

# -------------------------------------------------------------
# AWS TRANSFER FAMILY SFTP SERVER
# -------------------------------------------------------------
resource "aws_transfer_server" "bz_sftp" {
  protocols              = ["SFTP"]
  domain                 = "S3"
  identity_provider_type = "SERVICE_MANAGED"
  security_policy_name   = "TransferSecurityPolicy-2025-03"
  logging_role           = aws_iam_role.bz_sftp_logging_role.arn

  structured_log_destinations = [
    "${aws_cloudwatch_log_group.bz_sftp_logs.arn}:*"
  ]

  tags = merge(local.common_tags, {
    Name = "bz-sftp-${var.environment}"
  })
}

