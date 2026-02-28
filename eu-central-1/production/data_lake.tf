resource "aws_s3_bucket" "federated_forge_staging_bucket" {
  bucket = "federated-forge-staging-bucket"
  tags = merge(local.common_tags, {
    Name = "forge_staging_bucket"
    }
  )
}

resource "aws_s3_bucket" "federated_forge_staging_bucket1" {
  bucket = "federated-forge-staging-bucket-1"
  tags = merge(local.common_tags, {
    Name = "forge_staging_bucket_1"
    }
  )
}
