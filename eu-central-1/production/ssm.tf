resource "aws_ssm_parameter" "user_private_key" {
  for_each = var.sftp_users
  name     = "/${var.environment}/${var.team}/alpenmechanik/sftp/users/${each.value.user_name}"
  type     = "SecureString"
  value_wo = jsonencode({
    "user_name"   = each.value.user_name
    "private_key" = trimspace(tls_private_key.rsa_ssh_key[each.key].private_key_openssh)
  })
  value_wo_version = 1
}
