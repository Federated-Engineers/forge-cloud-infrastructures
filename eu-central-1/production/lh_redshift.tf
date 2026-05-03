resource "aws_redshift_cluster" "lief_holdings" {
  cluster_identifier = "lief-holdings-predictive-pricing"
  database_name      = "pricing_db"
  master_username    = "exampleuser"
  master_password    = "Mustbe8characters"
  node_type          = "ra3.large"
  cluster_type       = "single-node"

  tags = merge(local.common_tags, { client = "lief-holdings" })
}

