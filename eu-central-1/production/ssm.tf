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

resource "aws_ssm_parameter" "luminabricks_user_access_key" {
  name = "/${var.environment}/${var.team}/luminabricks/airbyte/access_key"
  type = "SecureString"
  value_wo = jsonencode({
    "access_key"        = aws_iam_access_key.luminabricks_airbyte_access_key.id
    "secret_access_key" = aws_iam_access_key.luminabricks_airbyte_access_key.secret
  })
  value_wo_version = 1
}
