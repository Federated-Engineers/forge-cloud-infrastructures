module "scardinavas_bucket" {
  source          = "../modules/s3_bucket"
  team            = var.team
  bucket-use-case = "Scardinavas-data-lake"
  service         = "s3"
  versioning      = "Enabled"
  environment     = var.environment
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle" {
  bucket = module.scardinavas_bucket.bucket_name

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

module "bbss_bucket" {
  source          = "../modules/s3_bucket"
  team            = var.team
  bucket-use-case = "BBSS-data-lake"
  service         = "s3"
  versioning      = "Enabled"
  environment     = var.environment
}

resource "aws_s3_bucket_lifecycle_configuration" "bbss_bucket_lifecycle" {
  bucket = module.bbss_bucket.bucket_name

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


# Nordic Peaks S3 bucket
# This bucket is used to store data for the Nordic Peaks project. It has three main zones:
# - Landing: where raw data is ingested
# - Processed: where data is processed and transformed
module "nordic-peaks-oslo" {
  source          = "../modules/s3_bucket"
  team            = var.team
  bucket-use-case = "nordic-peaks-oslo"
  service         = "s3"
  versioning      = "Enabled"
  environment     = var.environment
}


# bucket lifecycle
resource "aws_s3_bucket_lifecycle_configuration" "nordic_peaks" {

  bucket = module.nordic-peaks-oslo.bucket_name

  rule {
    id     = "transition-landing-zone-to-Glacier-IR"
    status = "Enabled"

    filter {
      prefix = "landing_zone/"
    }

    transition {
      days          = 180
      storage_class = "GLACIER_IR"
    }
  }
}
