
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
          module.horlogerie_data_lake.arn,
          "${module.horlogerie_data_lake.arn}/*",
          module.bbss_bucket.arn,
          "${module.bbss_bucket.arn}/*",
          "${module.alpenmechanik_bucket.arn}/*",
          module.mave-aqua-datalake.arn,
          "${module.mave-aqua-datalake.arn}/*",
          module.baltilogix_bucket.arn,
          "${module.baltilogix_bucket.arn}/*",
          "arn:aws:s3:::baltilogix-raw-ingestion",
          "arn:aws:s3:::baltilogix-raw-ingestion/*",
          "arn:aws:s3:::cocosurf-gear-datalake",
          "arn:aws:s3:::cocosurf-gear-datalake/*",
          module.nordic-peaks-oslo.arn,
          "${module.nordic-peaks-oslo.arn}/*",
          "${module.luminabricks_bucket.arn}/*",
          module.liffey_lux_linens.arn,
          "${module.liffey_lux_linens.arn}/*",
          module.deburf_bucket.arn,
          "${module.deburf_bucket.arn}/*"
        ]
      },

      {
        Sid    = "ReadSSMParameters"
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
        ]
        Resource = [
          "arn:aws:ssm:eu-central-1:049417293525:parameter/production/google-service-account/credentials",
          "arn:aws:ssm:eu-central-1:049417293525:parameter/production/forge/bbss/api-key",
          "arn:aws:ssm:eu-central-1:049417293525:parameter/supabase/database/credentials",
          "arn:aws:ssm:eu-central-1:049417293525:parameter/production/rds/credentials",
          "arn:aws:ssm:eu-central-1:049417293525:parameter/snowflake/airflow/private-key",
          "arn:aws:ssm:eu-central-1:049417293525:parameter/production/cocosurf/snowflake/dbt_user",
          "arn:aws:ssm:eu-central-1:049417293525:parameter/production/cocosurf/snowflake/dbt_user_password",

        ]
      },

      {
        Sid    = "GlueActions"
        Effect = "Allow"
        Action = [
          "glue:*"
        ]
        Resource = ["*"]
      },

      {
        Sid    = "DMSReplicationTaskControl"
        Effect = "Allow"
        Action = [
          "dms:StartReplicationTask",
          "dms:StopReplicationTask",
          "dms:DescribeReplicationTasks"
        ]
        Resource = ["*"]
      },
      {
        Sid    = "AllowAirflowRunECS"
        Effect = "Allow"
        Action = [
          "ecs:RunTask",
          "ecs:DescribeTasks",
        ]
        Resource = ["*",
        " arn:aws:ecs:eu-central-1:049417293525:task-definition/*"]
      },
      {
        Sid      = "AllowAirflowECSPassRole"
        Effect   = "Allow",
        Action   = "iam:PassRole"
        Resource = "*"
      },
      {
        Sid    = "AllowGetLogs"
        Effect = "Allow"
        Action = [
          "logs:GetLogEvents",
        ]
        Resource = ["*",
        "arn:aws:logs:eu-central-1:049417293525:log-group:/ecs/achs-dbt:log-stream:dbt/dbt-container/*"]
      },
    ]
  })
}
