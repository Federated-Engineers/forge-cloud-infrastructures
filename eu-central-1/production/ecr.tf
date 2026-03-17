resource "aws_ecr_repository" "forge_airflow" {
  name                 = "forge-airflow"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(local.common_tags, { Name = "forge-airflow" })
}

resource "aws_ecr_lifecycle_policy" "expire_unused_images" {
  repository = aws_ecr_repository.forge_airflow.name

  policy = <<EOF
  {
    "rules": [
      {
        "rulePriority": 1,
        "description": "Keep last 3 images only",
        "selection": {
          "tagStatus": "any",
          "countType": "imageCountMoreThan",
          "countNumber": 3
        },
        "action": {
          "type": "expire"
        }
      }
    ]
  }
  EOF
}
