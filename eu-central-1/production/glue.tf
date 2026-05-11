resource "aws_glue_catalog_database" "production-forge-moda-milano" {
  name        = "production-forge-moda-milano"
  description = "Catalog database for Moda Milano e-commerce data"

  tags = merge(local.common_tags, {
    region  = var.region
    service = "Glue"
  })
}