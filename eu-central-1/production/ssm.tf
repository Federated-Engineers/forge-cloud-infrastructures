resource "aws_ssm_parameter" "user_private_key" {
  name = "/${var.environment}/${var.team}/alpenmechanik/sftp/users/default"
  type = "SecureString"
  value_wo = jsonencode({
    "user_name"   = "default"
    "private_key" = trimspace(tls_private_key.rsa_ssh_key.private_key_openssh)
  })
  value_wo_version = 2
}
