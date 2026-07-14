resource "tls_private_key" "rsa_ssh_key" {
  for_each  = var.sftp_users
  algorithm = "RSA"
  rsa_bits  = 4096
}
