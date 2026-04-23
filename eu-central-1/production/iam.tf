data "aws_iam_user" "teammates" {
  for_each = toset([
    "oluwapelumi_oshundiya",
    "chikodi_obu"
  ])
  user_name = each.key
}

# Attach the Airflow policy bbss team
resource "aws_iam_user_policy_attachment" "teammate_bbss_access" {
  for_each = data.aws_iam_user.teammates

  user       = each.value.user_name
  policy_arn = aws_iam_policy.forge_airflow_policy.arn
}
