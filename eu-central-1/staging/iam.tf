#Terraform does not manage the `forge-data-engineers` IAM group as far as I'm aware

data "aws_iam_group" "forge_team" {
  group_name = "forge-data-engineers"
}


resource "aws_iam_user" "forge_staging_system_user" {
  name = "forge_staging_user"
  tags = local.common_tags
}


resource "aws_iam_policy" "forge_staging_s3_access" {
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
      }

    ]
  })
}


resource "aws_iam_user_policy_attachment" "forge_staging_user_s3_policy" {
  user       = aws_iam_user.forge_staging_system_user.name
  policy_arn = aws_iam_policy.forge_staging_s3_access.arn
}

resource "aws_iam_group_policy_attachment" "forge_team_s3_policy" {
  group      = data.aws_iam_group.forge_team.group_name
  policy_arn = aws_iam_policy.forge_staging_s3_access.arn
}
