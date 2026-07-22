
# resource "aws_transfer_server" "alpenmechanik_sftp_server" {
#   domain                          = "S3"
#   endpoint_type                   = "PUBLIC"
#   force_destroy                   = true
#   identity_provider_type          = "SERVICE_MANAGED"
#   ip_address_type                 = "IPV4"
#   security_policy_name            = "TransferSecurityPolicy-2018-11"
#   pre_authentication_login_banner = "AlpenMechanik SFTP Server - Unauthorized access is prohibited. All activities are monitored and logged."
#   protocols                       = ["SFTP"]

#   s3_storage_options {
#     directory_listing_optimization = "ENABLED"
#   }

#   tags = {
#     Name        = "AlpenMechanik SFTP Server"
#     Environment = var.environment
#     Team        = var.team
#   }
# }

# resource "aws_transfer_user" "alpenmechanik_sftp_user" {
#   server_id      = aws_transfer_server.alpenmechanik_sftp_server.id
#   user_name      = "default"
#   role           = aws_iam_role.sftp_user_role.arn
#   home_directory = "/${module.alpenmechanik_bucket.bucket_name}/default"

#   tags = {
#     Name        = "AlpenMechanik SFTP User"
#     Environment = var.environment
#     Team        = var.team
#   }
# }

# resource "aws_transfer_ssh_key" "alpenmechanik_sftp_users_ssh_key" {
#   server_id = aws_transfer_server.alpenmechanik_sftp_server.id
#   user_name = aws_transfer_user.alpenmechanik_sftp_user.user_name
#   body      = trimspace(tls_private_key.rsa_ssh_key.public_key_openssh)
# }
