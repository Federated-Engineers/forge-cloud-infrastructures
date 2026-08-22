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

resource "aws_glue_catalog_database" "forge-production-deburf" {
  name = "deburf_db"

  tags = merge(local.common_tags, {
    Owner   = "deburf",
resource "aws_glue_catalog_database" "HDG_db" {
  name = "forge-production-hdg_db"

  tags = merge(local.common_tags, {
    Owner   = "mave_aqua",
    Service = "forge-airflow"
  })
}
