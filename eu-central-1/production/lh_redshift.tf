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
  name   = "parameter-group-lief-holdings"
  family = "redshift-1.0"

  parameter {
    name  = "require_ssl"
    value = "true"
  }

  parameter {
    name = "wlm_json_configuration"
    value = jsonencode([
      {
        name              = "Short Query Acceleration"
        short_query_queue = true
      },
      {
        name       = "ETL Queue"
        auto_wlm   = true
        queue_type = "auto"
        priority   = "high"
        user_group = ["etl_users"]
        rules = [
          {
            rule_name = "log_large_etl_scan"
            predicate = [
              {
                metric_name = "query_blocks_read"
                operator    = ">"
                value       = 2097152
              }
            ]
            action = "log"
          }
        ]
      },
      {
        name                = "Analyst/Ad-Hoc Queue"
        auto_wlm            = true
        queue_type          = "auto"
        concurrency_scaling = "auto"
        user_group          = ["analysts"]
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

data "aws_subnet" "public_a" {
  id = "subnet-0613b8ccd258f4cca"
}

data "aws_subnet" "public_b" {
  id = "subnet-0af2d376a426b58bb"
}

resource "aws_redshift_subnet_group" "lief_holdings" {
  name        = "lief-holdings-subnet-group"
  description = "Subnet group for Lief Holdings Redshift cluster"
  subnet_ids  = [data.aws_subnet.public_a.id, data.aws_subnet.public_b.id]

  tags = merge(local.common_tags)
}

resource "aws_security_group" "redshift_sg" {
  name        = "lief-holdings-redshift-sg"
  description = "Security group for Lief Holdings Redshift cluster"
  vpc_id      = data.aws_subnet.public_a.vpc_id

  tags = merge(local.common_tags)
}

resource "aws_vpc_security_group_ingress_rule" "redshift_ingress" {
  security_group_id = aws_security_group.redshift_sg.id
  description       = "Allow inbound Redshift traffic"
  from_port         = 5439
  to_port           = 5439
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "redshift_egress" {
  security_group_id = aws_security_group.redshift_sg.id
  description       = "Allow all outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_redshift_cluster" "lief_holdings_redshift" {
  cluster_identifier           = "lief-holdings-predictive-pricing"
  database_name                = "pricing_db"
  master_username              = "lief_admin"
  master_password              = aws_ssm_parameter.redshift_master_password.value
  node_type                    = "ra3.large"
  cluster_type                 = "single-node"
  publicly_accessible          = true
  iam_roles                    = [aws_iam_role.lief_holdings_redshift.arn]
  cluster_parameter_group_name = aws_redshift_parameter_group.lief_holdings_group.name
  cluster_subnet_group_name    = aws_redshift_subnet_group.lief_holdings.name
  vpc_security_group_ids       = [aws_security_group.redshift_sg.id]
  preferred_maintenance_window = "sat:01:00-sat:03:00"

  tags = merge(local.common_tags, { client = "lief-holdings" })
}

