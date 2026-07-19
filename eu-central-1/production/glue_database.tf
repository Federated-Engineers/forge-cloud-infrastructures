resource "aws_glue_catalog_database" "scardinavas_db" {
  name = "forge-production-scardinavas"

  tags = merge(local.common_tags, {
    Owner   = "scardinavas",
    Service = "forge-airflow"
  })
}

resource "aws_glue_catalog_database" "mave_aqua_db" {
  name = "mave_aqua"

  tags = merge(local.common_tags, {
    Owner   = "mave_aqua",
    Service = "forge-airflow"
  })
}