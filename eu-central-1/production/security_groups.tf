
data "aws_vpc" "prod_vpc" {
  filter {
    name   = "tag:Name"
    values = ["secure-production"]
  }
}


resource "aws_security_group" "alpine_db_security_group" {
  name        = "database-security-group"
  description = "Enable access on port 5432 for Postgres"
  vpc_id      = data.aws_vpc.prod_vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "postgres_rds_ingress" {
  security_group_id = aws_security_group.alpine_db_security_group.id
  cidr_ipv4         = data.aws_vpc.prod_vpc.cidr_block

  from_port   = 5432
  ip_protocol = "tcp"
  to_port     = 5432
}
