resource "aws_glue_catalog_database" "forge-production-scardinavas" {
  name = "scardinavas_db"

  tags = merge(local.common_tags, {
    Owner   = "scardinavas",
    Service = "forge-airflow"
  })
}
resource "aws_glue_catalog_database" "mave_aqua_db" {
  name = "forge-production-mave-aqua"

  tags = merge(local.common_tags, {
    Owner   = "mave_aqua",
    Service = "forge-airflow"
  })
}
