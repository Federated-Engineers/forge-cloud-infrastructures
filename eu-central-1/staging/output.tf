output "bz_sftp_server_endpoint" {
  description = "SFTP endpoint hostname"
  value       = aws_transfer_server.bz_sftp.endpoint
}

output "bz_sftp_server_id" {
  description = "Transfer Family server ID"
  value       = aws_transfer_server.bz_sftp.id
}

output "bz_sftp_bucket_name" {
  description = "S3 bucket for SFTP file exchange"
  value       = module.bz_sftp_bucket.bucket_name
}
