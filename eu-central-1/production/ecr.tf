resource "aws_ecr_repository" "forge_airflow" {
  name                 = "forge-airflow"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(local.common_tags, { Name = "forge-airflow" })
}
