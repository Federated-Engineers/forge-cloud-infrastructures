# our s3 bucket will be provisioned from the existing s3 module 

module "forge_data_lake" {
  source = "../modules/s3-bucket"  # source of the module

  # the variables needed in provisioning the s3 bucket
  environment = var.environment
  team = var.team
  bucket-use-case = var.bucket-use-case
  service = var.service
  versioning = var.versioning
}

