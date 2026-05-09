resource "aws_glue_catalog_database" "forge_moda_milano_production_catalog" {
  name        = "forge_moda_milano_production_catalog"
  description = "Data catalog for Moda Milano e-commerce data"
  tags = {
    environment = "production"
    team        = "forge"
    region      = var.region
    service     = "Glue"
  }
}
