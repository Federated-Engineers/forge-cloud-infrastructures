resource "aws_iam_policy" "airflow_policy" {
  name        = "forge-airflow-access-policy"
  description = "Allow Airflow to access aws resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Readandwrite"
        Effect = "Allow"
        Action = [
          "s3:List*",
          "s3:*object*"
        ]
        Resource = [
          module.scardinavas_bucket.arn,
          "${module.scardinavas_bucket.arn}/*",
          module.bbss_bucket.arn,
          "${module.bbss_bucket.arn}/*"
        ]
      },

      {
        Sid    = "ReadSSMParameters"
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ]
        Resource = [
          "arn:aws:ssm:eu-central-1:049417293525:parameter/production/google-service-account/credentials",
          "arn:aws:ssm:eu-central-1:049417293525:parameter/production/forge/bbss/api-key",
          "arn:aws:ssm:eu-central-1:049417293525:parameter/supabase/database/credentials"

        ]
      },

      {
        Sid    = "GlueActions"
        Effect = "Allow"
        Action = [
          "glue:*"
        ]
        Resource = ["*"]
      }
    ]
  })
}

