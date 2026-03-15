
# versioning is disabled, and there's no `prevent_destroy` lifecycle.
# Destruction protections are intentionally relaxed in the staging bucket.


resource "aws_s3_bucket" "forge_staging_bkt" {
  bucket = "forge-staging-bucket"
  force_destroy = true
  tags = merge(local.common_tags, {
    Name = "forge_staging_bucket"
    }
  )

}

resource "aws_s3_bucket_versioning" "forge_staging_versioning" {
  bucket = aws_s3_bucket.forge_staging_bkt.id
  versioning_configuration {
    status = "Disabled"  #Not sure if we want to enable this yet
  }
}

#Also we need to consider if and what lifecycle policies we want to use