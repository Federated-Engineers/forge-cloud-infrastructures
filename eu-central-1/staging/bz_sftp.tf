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
  protocols              = ["SFTP"]

  tags = local.common_tags
}


resource "aws_transfer_user" "rhine_valley_repair" {
  server_id = aws_transfer_server.bz_sftp.id
  user_name = "rhine-valley-repair"
  role      = aws_iam_role.bz_sftp_user_role.arn

  home_directory_type = "LOGICAL"

  home_directory_mappings {
    entry  = "/"
    target = "/${module.bz_sftp_bucket.bucket_name}/bieler-zeitwerk"
  }

  tags = local.common_tags
}