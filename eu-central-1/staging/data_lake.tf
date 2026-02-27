resource "aws_s3_bucket" "federated_forge_staging_bucket" {
  bucket = "federated-forge-staging-bucket"
  tags = merge(local.common_tags, {
    Name = "forge_staging_bucket"
    }
  )
}
