module "forge_data_lake" {
    source = "../modules/s3-bucket"

    environment = var.environment
    team = var.team
    bucket-use-case = var.bucket-use-case
    service = var.service
    versioning = var.versioning
}




