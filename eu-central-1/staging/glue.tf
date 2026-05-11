resource "aws_glue_catalog_database" "federated-engineers-forge-staging-database" {
  name        = "federated-engineers-forge-staging-database"
  description = "Catalog database for staging operations"

  tags = merge(local.common_tags, {
    region  = var.region
    service = "Glue"
  })
}