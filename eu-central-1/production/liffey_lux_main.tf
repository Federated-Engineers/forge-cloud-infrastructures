####### BUCKETS AND LIFECYCLE##########
module "liffey_lux_linens" {
  source          = "../modules/s3_bucket"
  team            = var.team
  bucket-use-case = "liffey-lux-linens"
  service         = "s3"
  versioning      = "Enabled"
  environment     = var.environment
}

module "liffey_lux_athena_query_result" {
  source          = "../modules/s3_bucket"
  team            = var.team
  bucket-use-case = "athena-query-results"
  service         = "s3"
  versioning      = "Enabled"
  environment     = var.environment
}

resource "aws_s3_bucket_lifecycle_configuration" "liffey_lux_linens" {

  bucket = module.liffey_lux_linens.bucket_name

  rule {
    id     = "transition-landing-zone-to-Glacier-IR"
    status = "Enabled"

    filter {
      prefix = "landing_zone/"
    }

    transition {
      days          = 180
      storage_class = "GLACIER_IR"
    }
  }
}


####### AWS GLUE DB ##########
resource "aws_glue_catalog_database" "liffey_luxury_linens" {
  name        = "liffey_luxury_linens_db"
  description = "Curated zone database for Liffey Luxury Linens pipeline"
}


####### ATHENA WORKGROUP ##########
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

