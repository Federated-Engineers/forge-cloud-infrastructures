resource "aws_ssm_parameter" "user_private_key" {
  name = "/${var.environment}/${var.team}/alpenmechanik/sftp/users/default/private_key"
  type = "SecureString"
  value_wo = jsonencode({
    "user_name"   = "default"
    "private_key" = trimspace(tls_private_key.rsa_ssh_key.private_key_openssh)
  })
  value_wo_version = 2
}

resource "aws_ssm_parameter" "user_public_key" {
  name = "/${var.environment}/${var.team}/alpenmechanik/sftp/users/default/public_key"
  type = "SecureString"
  value_wo = jsonencode({
    "user_name"  = "default"
    "public_key" = trimspace(tls_private_key.rsa_ssh_key.public_key_openssh)
  })
  value_wo_version = 1
}

resource "aws_ssm_parameter" "spreekauf_redshift_password" {
  name        = "/spreekauf-master-password"
  description = "SpreeKauf Redshift cluster master password"
  type        = "SecureString"
  value       = random_string.spreekauf_password.result
}