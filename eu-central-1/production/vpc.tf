resource "aws_vpc" "ghost_bridge_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = "ghost-bridge-vpc"
  })
}

resource "aws_subnet" "ghost_bridge_private_subnet_1" {
  vpc_id                  = aws_vpc.ghost_bridge_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    Name = "ghost-bridge-private-subnet-1"
  })
}

resource "aws_subnet" "ghost_bridge_private_subnet_2" {
  vpc_id                  = aws_vpc.ghost_bridge_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-central-1b"
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    Name = "ghost-bridge-private-subnet-2"
  })
}

resource "aws_route_table" "ghost_bridge_private_subnet_rtb" {
  vpc_id = aws_vpc.ghost_bridge_vpc.id

  tags = merge(local.common_tags, {
    Name = "ghost-bridge-private-subnet-rtb"
  })
}

resource "aws_route_table_association" "ghost_bridge_private_rtb_1" {
  subnet_id      = aws_subnet.ghost_bridge_private_subnet_1.id
  route_table_id = aws_route_table.ghost_bridge_private_subnet_rtb.id
}

resource "aws_route_table_association" "ghost_bridge_private_rtb_2" {
  subnet_id      = aws_subnet.ghost_bridge_private_subnet_2.id
  route_table_id = aws_route_table.ghost_bridge_private_subnet_rtb.id
}

resource "aws_vpc_endpoint" "ghost_bridge_s3_gateway" {
  vpc_id            = aws_vpc.ghost_bridge_vpc.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.ghost_bridge_private_subnet_rtb.id
  ]

  tags = merge(local.common_tags, {
    Name = "ghost-bridge-s3-gateway"
  })
}

resource "aws_security_group" "ghost_bridge_lambda_sg" {
  name        = "ghost-bridge-lambda-sg"
  description = "Security group for Ghost-Bridge Lambda"
  vpc_id      = aws_vpc.ghost_bridge_vpc.id

  tags = merge(local.common_tags, {
    Name = "ghost-bridge-lambda-sg"
  })
}

resource "aws_vpc_security_group_egress_rule" "ghost_bridge_lambda_sg_egress" {
  security_group_id = aws_security_group.ghost_bridge_lambda_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_security_group" "ghost_bridge_rds_sg" {
  name        = "ghost-bridge-rds-sg"
  description = "Security group for Ghost-Bridge PostgreSQL RDS"
  vpc_id      = aws_vpc.ghost_bridge_vpc.id

  tags = merge(local.common_tags, {
    Name = "ghost-bridge-rds-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "ghost_bridge_rds_from_lambda" {
  security_group_id            = aws_security_group.ghost_bridge_rds_sg.id
  referenced_security_group_id = aws_security_group.ghost_bridge_lambda_sg.id

  from_port   = 5432
  to_port     = 5432
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "ghost_bridge_rds_sg_egress" {
  security_group_id = aws_security_group.ghost_bridge_rds_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_security_group" "ghost_bridge_secrets_endpoint_sg" {
  name        = "ghost-bridge-secrets-endpoint-sg"
  description = "Security group for Ghost-Bridge Secrets Manager VPC endpoint"
  vpc_id      = aws_vpc.ghost_bridge_vpc.id

  tags = merge(local.common_tags, {
    Name = "ghost-bridge-secrets-endpoint-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "ghost_bridge_secrets_from_lambda" {
  security_group_id            = aws_security_group.ghost_bridge_secrets_endpoint_sg.id
  referenced_security_group_id = aws_security_group.ghost_bridge_lambda_sg.id

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

resource "aws_vpc_endpoint" "ghost_bridge_secrets_manager" {
  vpc_id = aws_vpc.ghost_bridge_vpc.id

  service_name = "com.amazonaws.${var.region}.secretsmanager"

  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.ghost_bridge_private_subnet_1.id,
    aws_subnet.ghost_bridge_private_subnet_2.id
  ]

  security_group_ids = [
    aws_security_group.ghost_bridge_secrets_endpoint_sg.id
  ]

  private_dns_enabled = true

  tags = merge(local.common_tags, {
    Name = "ghost-bridge-secrets-manager-endpoint"
  })
}
