resource "aws_glue_catalog_database" "scardinavas_db" {
  name = "forge-production-scardinavas"

  tags = merge(local.common_tags, {
    Owner   = "scardinavas",
    Service = "forge-airflow"
  })
}
