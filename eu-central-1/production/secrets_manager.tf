resource "random_password" "db_password" {
  length  = 20
  special = true
}

resource "aws_secretsmanager_secret" "ghost_bridge_db_secret" {
  name        = "ghost-bridge-db-secret"
  description = "Database credentials for Ghost-Bridge PostgreSQL"

  tags = merge(local.common_tags, {
    Name = "ghost-bridge-db-secret"
  })
}

resource "aws_secretsmanager_secret_version" "ghost_bridge_db_secret_version" {
  secret_id = aws_secretsmanager_secret.ghost_bridge_db_secret.id

  secret_string = jsonencode({
    username = "postgres"
    password = random_password.db_password.result
    dbname   = "ghost_bridge_db"
    host     = aws_db_instance.ghost_bridge_rds.address
    port     = 5432
  })
}
