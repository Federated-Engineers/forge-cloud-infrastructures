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
module "mave-aqua-datalake" {
  source          = "../modules/s3_bucket"
  team            = var.team
  bucket-use-case = "mave-aqua-data-lake"

  service     = "s3"
  versioning  = "Enabled"
  environment = var.environment
}
module "bbss_bucket" {
  source          = "../modules/s3_bucket"
  team            = var.team
  bucket-use-case = "BBSS-data-lake"

  service     = "s3"
  versioning  = "Enabled"
  environment = var.environment
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

module "nordic-peaks-oslo" {
  source          = "../modules/s3_bucket"
  team            = var.team
  bucket-use-case = "nordic-peaks-oslo"
  service         = "s3"
  versioning      = "Enabled"
  environment     = var.environment
}

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

module "alpenmechanik_bucket" {
  source          = "../modules/s3_bucket"
  team            = var.team
  bucket-use-case = "AlpenMechanik-SFTP"
  service         = "s3"
  versioning      = "Enabled"
  environment     = var.environment
}
  
resource "aws_s3_bucket_lifecycle_configuration" "alpenmechanik_bucket_lifecycle" {
  bucket = module.alpenmechanik_bucket.bucket_name

  rule {
    id     = "transition-to-glacier-instant-retrieval"
    status = "Enabled"

    filter {
      prefix = "repairs/"
    }

    transition {
      days          = 180
      storage_class = "GLACIER_IR"
    }
  }
}