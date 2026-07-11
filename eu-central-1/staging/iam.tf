resource "aws_iam_user" "forge-user" {
  name = "forge-user"
}


resource "aws_iam_policy" "forge-team-policy" {
  name        = "forge_team_policy"
  description = "Forge team policy"


  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListBucket",
        ]
        Effect   = "Allow"
        Resource = "placeholder.arn"
      },

      {
        Action = [
          "s3:*Object",
        ]
        Effect   = "Allow"
        Resource = "placeholder.arn/*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "forge-team-policy-attachment" {
  user       = aws_iam_user.forge-user.name
  policy_arn = aws_iam_policy.forge-team-policy.arn
}
