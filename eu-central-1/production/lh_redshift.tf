resource "random_password" "password" {
  length  = 16
  special = true
}

resource "aws_ssm_parameter" "redshift_master_password" {
  name        = "/${var.environment}/${var.team}/redshift/lief-holdings/master-password"
  description = "Master password for the Lief Holdings Redshift cluster"
  type        = "SecureString"
  value       = random_password.lief_holdings_password.result
}

resource "aws_redshift_cluster" "lief_holdings" {
  cluster_identifier  = "lief-holdings-predictive-pricing"
  database_name       = "pricing_db"
  master_username     = var.redshift_master_username
  master_password     = aws_ssm_parameter.redshift_master_password.value
  node_type           = "ra3.large"
  cluster_type        = "single-node"
  publicly_accessible = true

  tags = merge(local.common_tags, { client = "lief-holdings" })
}

