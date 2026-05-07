data "aws_s3_bucket" "staging_data_lake" {
  bucket = "forge_data_lake"
} #only for testing


resource "aws_athena_workgroup" "moda_milano" {
  name        = "moda_milano"
  description = "Athena workgroup for the moda milano lakehouse"

  configuration {

    result_configuration {
      output_location = "s3://${data.aws_s3_bucket.staging_data_lake.bucket}/moda_milano/query_results/" #test loc

      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }
  }

  tags = {
    environment = "production"
    team        = "forge"
    service     = "athena"
  }
}