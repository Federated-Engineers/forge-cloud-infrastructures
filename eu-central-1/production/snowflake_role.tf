resource "aws_iam_role" "snowflake_s3_role" {
  name        = "forge-lonestar-snowflake-role"
  description = "Allow Snowflake storage integration to assume role for S3 access"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowSnowflakeAssume"
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          AWS = "arn:aws:iam::049417293525:root"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "snowflake_s3_policy" {
  name        = "forge-lonestar-snowflake-policy"
  description = "Allow Snowflake to read from lone-star-assurance-lake"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Read"
        Effect = "Allow"
        Action = [
          "s3:List*",
          "s3:Get*"
        ]
        Resource = [
          "arn:aws:s3:::lone-star-assurance-lake",
          "arn:aws:s3:::lone-star-assurance-lake/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "snowflake_s3_attachment" {
  role       = aws_iam_role.snowflake_s3_role.name
  policy_arn = aws_iam_policy.snowflake_s3_policy.arn
}
