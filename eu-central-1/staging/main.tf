resource "aws_s3_bucket" "federated-engineers-bucket" {
  bucket = lower("federated-${var.environment}-${var.team}-data-lake")

  tags = merge(local.common_tags, {
    Name    = "federated-engineers-${var.environment}-${var.team}-data-lake"
  })
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.federated-engineers-bucket.id

  versioning_configuration {
    status = var.versioning
  }
}