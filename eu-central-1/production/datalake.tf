resource "aws_s3_bucket_lifecycle_configuration" "baltilogix_cleanup" {
  bucket = "baltilogix-raw-ingestion"

  rule {
    id     = "delete-small-files"
    status = "Enabled"

    filter {
      prefix = "raw-ingestion/"
    }

    expiration {
      days = 30
    }
  }
}