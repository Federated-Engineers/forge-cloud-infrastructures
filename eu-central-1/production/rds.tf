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


# resource "aws_db_subnet_group" "ghost_bridge_db_subnet_group" {
#   name = "ghost-bridge-db-subnet-group"

#   subnet_ids = [
#     aws_subnet.ghost_bridge_private_subnet_1.id,
#     aws_subnet.ghost_bridge_private_subnet_2.id
#   ]

#   tags = merge(local.common_tags, {
#     Name = "ghost-bridge-db-subnet-group"
#   })
# }

# resource "aws_db_instance" "ghost_bridge_rds" {
#   identifier = "ghost-bridge-postgres"

#   engine         = "postgres"
#   engine_version = "17.5"

#   instance_class = "db.t4g.micro"

#   allocated_storage = 20
#   storage_type      = "gp3"

#   db_name  = "ghost_bridge_db"
#   username = "postgres"
#   password = random_password.db_password.result

#   db_subnet_group_name = aws_db_subnet_group.ghost_bridge_db_subnet_group.name
#   vpc_security_group_ids = [
#     aws_security_group.ghost_bridge_rds_sg.id
#   ]

#   publicly_accessible = false

#   multi_az = false

#   backup_retention_period = 7

#   deletion_protection = false
#   skip_final_snapshot = true

#   tags = merge(local.common_tags, {
#     Name = "ghost-bridge-postgres"
#   })
# }


# resource "aws_db_subnet_group" "ghost_bridge_db_subnet_group" {
#   name = "ghost-bridge-db-subnet-group"

#   subnet_ids = [
#     data.aws_subnet.ghost_bridge_private_subnet_1.id,
#     data.aws_subnet.ghost_bridge_private_subnet_2.id
#   ]

#   tags = merge(local.common_tags, {
#     Name = "ghost-bridge-db-subnet-group"
#   })
# }

# resource "aws_db_instance" "ghost_bridge_rds" {
#   identifier = "ghost-bridge-postgres"

#   engine         = "postgres"
#   engine_version = "17.5"

#   instance_class = "db.t4g.micro"

#   allocated_storage = 20
#   storage_type      = "gp3"

#   db_name  = "ghost_bridge_db"
#   username = "postgres"
#   password = random_password.db_password.result

#   db_subnet_group_name = aws_db_subnet_group.ghost_bridge_db_subnet_group.name

#   vpc_security_group_ids = [
#     aws_security_group.ghost_bridge_rds_sg.id
#   ]

#   publicly_accessible = false

#   multi_az = false

#   backup_retention_period = 7

#   deletion_protection = false
#   skip_final_snapshot = true

#   tags = merge(local.common_tags, {
#     Name = "ghost-bridge-postgres"
#   })
# }

