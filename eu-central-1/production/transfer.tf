
resource "aws_transfer_server" "alpenmechanik_sftp_server" {
  domain                          = "S3"
  endpoint_type                   = "PUBLIC"
  force_destroy                   = true
  identity_provider_type          = "SERVICE_MANAGED"
  ip_address_type                 = "IPV4"
  security_policy_name            = "TransferSecurityPolicy-2018-11"
  pre_authentication_login_banner = "AlpenMechanik SFTP Server - Unauthorized access is prohibited. All activities are monitored and logged."
  protocols                       = ["SFTP"]

  s3_storage_options {
    directory_listing_optimization = "ENABLED"
  }

  tags = {
    Name        = "AlpenMechanik SFTP Server"
    Environment = var.environment
    Team        = var.team
  }
}
