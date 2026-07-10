module "s3_bucket" {
  source = "../modules/s3_bucket"

  bucket_name = lower(
    "federated-${var.team}-${var.environment}-scardinavas-bucket"
  )

  tags = local.common_tags

}

resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle" {
  bucket = module.s3_bucket.bucket_name

  rule {
    id     = "transition-to-glacier-instant-retrieval"
    status = "Enabled"

    filter {
      prefix = "raw/"
    }

    transition {
      days          = 180
      storage_class = "GLACIER_IR"
    }
  }
}