data "aws_subnet" "subnet_a" {
  filter {
    name   = "tag:Name"
    values = ["secure-production-private-a"]
  }
}


data "aws_subnet" "subnet_b" {
  filter {
    name   = "tag:Name"
    values = ["secure-production-private-b"]
  }
}


resource "aws_db_subnet_group" "forge_alpine_heritage_db_subnet_group" {
  name       = "alpine-heritage-rds-subnet-group"
  subnet_ids = [data.aws_subnet.subnet_a.id, data.aws_subnet.subnet_b.id]

  tags = {
    Name = "Alpine Heritage RDS subnet group"
  }
}