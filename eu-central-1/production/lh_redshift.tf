resource "random_password" "lief_holdings_password" {
  length  = 16
  special = true
}

resource "aws_ssm_parameter" "redshift_master_password" {
  name        = "/${var.environment}/${var.team}/redshift/lief-holdings/master-password"
  description = "Master password for the Lief Holdings Redshift cluster"
  type        = "SecureString"
  value       = random_password.lief_holdings_password.result
}

resource "aws_iam_role" "lief_holdings_redshift" {
  name        = "production-lh-redshift-role"
  description = "Allows the Lief Holdings Redshift cluster to access AWS resources"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "redshift.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(local.common_tags, { client = "lief-holdings" })
}

resource "aws_redshift_parameter_group" "lief_holdings_group" {
  name   = "parameter-group-lief-holdings-terraform"
  family = "redshift-1.0"

  parameter {
    name  = "require_ssl"
    value = "true"
  }

  parameter {
    name  = "enable_user_activity_logging"
    value = "true"
  }

  parameter {
    name = "wlm_json_configuration"
    value = jsonencode([{
      short_query_queue = true
      },
      {
        name                  = "ETL Queue"
        memory_percent_to_use = 40
        query_concurrency     = 3
        user_group            = ["etl_users"]
        rules = [
          {
            rule_name = "abort_large_scan"
            predicate = [
              {
                metric_name = "query_blocks_read"
                operator    = ">"
                value       = 2097152
              }
            ]
            action = "abort"
          }
        ]
      },
      {
        name                  = "Analyst/Ad-Hoc Queue"
        memory_percent_to_use = 60
        query_concurrency     = 5
        concurrency_scaling   = "auto"
        rules = [
          {
            rule_name = "abort_large_scan"
            predicate = [
              {
                metric_name = "query_blocks_read"
                operator    = ">"
                value       = 2097152
              }
            ]
            action = "abort"
          },
          {
            rule_name = "downgrade_heavy_cpu"
            predicate = [
              {
                metric_name = "query_cpu_usage_percent"
                operator    = ">"
                value       = 80
              },
              {
                metric_name = "query_cpu_time"
                operator    = ">"
                value       = 1200
              }
            ]
            action = "change_query_priority"
            value  = "lowest"
          }
        ]
      }
    ])
  }
}

resource "aws_redshift_cluster" "lief_holdings" {
  cluster_identifier  = "lief-holdings-predictive-pricing"
  database_name       = "pricing_db"
  master_username     = var.redshift_master_username
  master_password     = aws_ssm_parameter.redshift_master_password.value
  node_type           = "ra3.large"
  cluster_type        = "single-node"
  publicly_accessible = true
  iam_roles           = [aws_iam_role.lief_holdings_redshift.arn]

  tags = merge(local.common_tags, { client = "lief-holdings" })
}

