resource "aws_athena_workgroup" "liffey_luxury_linens" {
  name          = "liffey_luxury_linens_workgroup"
  state         = "ENABLED"
  force_destroy = true

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${module.liffey_lux_athena_query_result.bucket_name}/results/"

      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }

    bytes_scanned_cutoff_per_query = 1073741824 # 1 GB
  }
}

####### ATHENA WORKGROUP POLICY ##########
resource "aws_iam_policy" "athena_query_access" {
  name = "liffey-athena-analyst-access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Deny"
        Action   = ["athena:StartQueryExecution"]
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "athena:WorkGroup" = "liffey_luxury_linens_workgroup"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "athena:StartQueryExecution",
          "athena:GetQueryExecution",
          "athena:GetQueryResults",
          "athena:StopQueryExecution",
          "athena:GetWorkGroup",
          "athena:ListWorkGroups",
          "ssm:GetParameter",
          "ssm:GetParameters"
        ]
        Resource = "*"
      }
    ]
  })
}

