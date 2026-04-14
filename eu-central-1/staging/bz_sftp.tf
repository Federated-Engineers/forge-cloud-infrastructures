# Bieler Zeitwerk SFTP Infrastructure

module "bz_sftp_bucket" {
  source = "../modules/s3-bucket"

  environment     = var.environment
  team            = var.team
  bucket-use-case = "sftp"
  service         = "transfer-family"
  versioning      = "Enabled"
}

resource "aws_iam_role" "bz_sftp_user_role" {
  name = "bz-sftp-user-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "transfer.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy" "bz_sftp_user_s3_policy" {
  name = "bz-sftp-user-s3-policy"
  role = aws_iam_role.bz_sftp_user_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = module.bz_sftp_bucket.arn
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = "${module.bz_sftp_bucket.arn}/bieler-zeitwerk/*"
      }
    ]
  })
}

resource "aws_transfer_server" "bz_sftp" {

  tags = merge(local.common_tags, {
    Name = "bz-sftp-${var.environment}"
  })
}

