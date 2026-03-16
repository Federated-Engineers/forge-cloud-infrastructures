#Terraform does not manage the `forge-data-engineers` IAM group as far as I'm aware

data "aws_iam_group" "forge_team" {
  group_name = "forge-data-engineers"
}


resource "aws_iam_policy" "forge_team_staging_access" {
  name        = "forge_staging_s3-access"
  description = "Allow read + write to staging bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action = ["s3:ListBucket"]
        Resource = aws_s3_bucket.federated_forge_staging_bkt.arn
      },

      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ]
        Resource = "${aws_s3_bucket.federated_forge_staging_bkt.arn}/*"
      },

      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter"
        ]
        Resource = "arn:aws:ssm:eu-central-1:049417293525:parameter/production/google-service-account/credentials"
      }
      # The SSM parameter seems to belong to prod
    ]
  })
}

resource "aws_iam_group_policy_attachment" "forge_team_staging_policy" {
  group      = data.aws_iam_group.forge_team.group_name
  policy_arn = aws_iam_policy.forge_team_staging_access.arn
}