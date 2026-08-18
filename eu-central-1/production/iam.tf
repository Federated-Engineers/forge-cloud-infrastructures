resource "aws_iam_role" "sftp_user_role" {
  name        = "AlpenMechanik_SFTP_User_Role"
  description = "IAM role for SFTP users to access the S3 bucket through a Transfer Family Server"
  path        = "/forge/alpenmechanik/sftp/"
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
  path        = "/forge/alpenmechanik/sftp/"
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
          "arn:aws:s3:::${module.alpenmechanik_bucket.bucket_name}"
        ],
        "Condition" : {
          "StringLike" : {
            "s3:prefix" : [
              "${module.alpenmechanik_bucket.bucket_name}/*",
              "${module.alpenmechanik_bucket.bucket_name}"
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
        "Resource" : "arn:aws:s3:::${module.alpenmechanik_bucket.bucket_name}/*"
      }
    ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "sftp_user_role_policy_attachment" {
  role       = aws_iam_role.sftp_user_role.name
  policy_arn = aws_iam_policy.sftp_user_role_policy.arn
}

resource "aws_iam_role" "ghost_bridge_lambda_role" {
  name        = "ghost-bridge-lambda-role"
  description = "IAM role for Ghost-Bridge Lambda function"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "lambda.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "ghost-bridge-lambda-role"
  })
}

resource "aws_iam_policy" "ghost_bridge_lambda_policy" {
  name        = "ghost-bridge-lambda-policy"
  description = "Least privilege policy for Ghost-Bridge Lambda"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [

      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"

        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]

        Resource = "arn:aws:logs:*:*:*"
      },

      {
        Sid    = "SecretsManager"
        Effect = "Allow"

        Action = [
          "secretsmanager:GetSecretValue"
        ]

        Resource = aws_secretsmanager_secret.ghost_bridge_db_secret.arn
      },

      {
        Sid    = "S3Access"
        Effect = "Allow"

        Action = [
          "s3:GetObject"
        ]

        Resource = "arn:aws:s3:::munchen-auto-munich/*"
      },

      {
        Sid    = "LambdaVPCAccess"
        Effect = "Allow"

        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ]

        Resource = "*"
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "ghost-bridge-lambda-policy"
  })
}

resource "aws_iam_role_policy_attachment" "ghost_bridge_lambda_policy_attachment" {
  role       = aws_iam_role.ghost_bridge_lambda_role.name
  policy_arn = aws_iam_policy.ghost_bridge_lambda_policy.arn
}
