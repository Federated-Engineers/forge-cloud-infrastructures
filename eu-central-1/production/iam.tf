resource "aws_iam_role" "sftp_user_role" {
  name        = "AlpenMechanik_SFTP_User_Role"
  description = "IAM role for SFTP users to access the S3 bucket through a Transfer Family Server"
  path        = "forge/alpenmechanik/sftp"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "transfer.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "sftp_user_role_policy" {
  name        = "AlpenMechanik_SFTP_User_Role_Policy"
  description = "IAM policy form SFTP users to access S3 Buckets objects through Transfer Family Server"
  path        = "forge/alpenmechanik/sftp"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowListingOfUserFolder",
        "Action" : [
          "s3:ListBucket"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "arn:aws:s3:::${aws_s3_bucket.transfer_family_bucket.id}"
        ],
        "Condition" : {
          "StringLike" : {
            "s3:prefix" : [
              "${aws_s3_bucket.transfer_family_bucket.id}/*",
              "${aws_s3_bucket.transfer_family_bucket.id}"
            ]
          }
        }
      },
      {
        "Sid" : "HomeDirObjectAccess",
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:DeleteObjectVersion",
          "s3:GetObjectVersion",
          "s3:GetObjectACL",
          "s3:PutObjectACL"
        ],
        "Resource" : "arn:aws:s3:::${aws_s3_bucket.transfer_family_bucket.id}/*"
      }
    ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "sftp_user_role_policy_attachment" {
  role       = aws_iam_role.sftp_user_role.name
  policy_arn = aws_iam_policy.sftp_user_role_policy.arn
}
