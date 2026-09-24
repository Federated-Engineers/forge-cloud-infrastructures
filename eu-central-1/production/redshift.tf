resource "aws_redshift_cluster" "spreekauf_analytics_db_cluster" {
  cluster_identifier        = "spreekauf-redshift-cluster"
  database_name             = "spreekaufdb"
  master_username           = "spreekauf_redshift"
  node_type                 = "ra3.large"
  cluster_type              = "single-node"
  cluster_subnet_group_name = forge_spreekauf_analytics_redshift_subnet_group
  vpc_security_group_ids    = [aws_security_group.spreekauf_db_security_group.id]
  publicly_accessible       = false
  manage_master_password    = true
}
