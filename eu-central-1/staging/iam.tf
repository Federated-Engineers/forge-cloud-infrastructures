data "aws_iam_group" "forge_team" {
  group_name = "forge-data-engineers"
}


resource "aws_iam_policy" "forge-team-generic-access" {
  name        = "forge_team_generic_access"
  description = "Forge team access policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action = ["s3:ListBucket"]
        Resource = [module.forge_data_lake.arn]
      },

      {
        Effect = "Allow"
        Action = ["s3:*Object"]
        Resource = "${module.forge_data_lake.arn}/*"
      },

      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter"
        ]
        Resource = "arn:aws:ssm:eu-central-1:049417293525:parameter/production/google-service-account/credentials"
      }

    ]
  })
}

resource "aws_iam_group_policy_attachment" "forge_team_staging_policy" {
  group      = data.aws_iam_group.forge_team.group_name
  policy_arn = aws_iam_policy.forge-team-generic-access.arn
}

resource "aws_iam_user" "forge_generic_user" {
  name = "forge-user"

  tags = {
    Team = "forge"
    Environment = "staging"
  }
}

resource "aws_iam_access_key" "forge_generic_user" {
  user = aws_iam_user.forge_generic_user.name
}

output "forge_generic_access_key_id" {
  value     = aws_iam_access_key.forge_generic_user.id
  sensitive = true
}

output "forge_generic_secret_access_key" {
  value     = aws_iam_access_key.forge_generic_user.secret
  sensitive = true
}

resource "aws_iam_user_policy_attachment" "forge_user_staging_policy" {
  user       = aws_iam_user.forge_generic_user.name
  policy_arn = aws_iam_policy.forge-team-generic-access.arn
}
