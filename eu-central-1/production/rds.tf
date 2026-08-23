resource "aws_db_instance" "ctp_db_instance" {
  allocated_storage           = 100
  db_name                     = "forge_alpine_heritage"
  engine                      = "postgres"
  port                        = 5432
  engine_version              = "16.11"
  instance_class              = "db.t3.small"
  multi_az                    = false
  db_subnet_group_name        = aws_db_subnet_group.forge_alpine_heritage_db_subnet_group.name
  vpc_security_group_ids      = [aws_security_group.alpine_db_security_group.id]
  username                    = "alpine_postgres"
  manage_master_user_password = true
  skip_final_snapshot         = true
  publicly_accessible         = false


  tags = {
    Environment = var.environment
  }
}
