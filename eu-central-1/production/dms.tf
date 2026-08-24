data "aws_iam_role" "dms_vpc_role" {
  name = "dms-vpc-role"
}

resource "aws_iam_role_policy_attachment" "dms_vpc_role_policy" {
  role       = data.aws_iam_role.dms_vpc_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
}

resource "aws_iam_role" "dms_s3_target_role" {
  name = "dms-logistics-s3-target-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "dms.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "dms_s3_target_policy" {
  name = "dms-logistics-s3-target-policy"
  role = aws_iam_role.dms_s3_target_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [
          module.deburf_bucket.arn,
          "${module.deburf_bucket.arn}/*"
        ]
      }
    ]
  })
}

data "aws_vpc" "production" {
  tags = {
    Environment = "production"
    Name        = "dms-homogeneous-project-vpc"
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.production.id]
  }

  filter {
    name   = "tag:Name"
    values = ["secure-production-private-*"]
  }

  tags = {
    Environment = "production"
  }
}

resource "aws_dms_replication_subnet_group" "deburf_sb_group" {
  replication_subnet_group_id          = "dms-logistics-subnet-group"
  replication_subnet_group_description = "Subnet group for the DMS logistics replication instance"
  subnet_ids                           = data.aws_subnets.public.ids
}

resource "aws_security_group" "replication_instance" {
  name        = "dms-logistics-repl-sg"
  description = "Security group for the DMS logistics replication instance"
  vpc_id      = data.aws_vpc.production.id

  egress {
    description = "Allow all outbound (reaches source RDS on 5432 + S3)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "allow_dms_to_source_rds" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = "sg-0b055fc6e21cad80c"
  source_security_group_id = aws_security_group.replication_instance.id
  description              = "Allow DMS replication instance to reach source RDS PostgreSQL"
}

resource "aws_dms_replication_instance" "deburf_dms_ri" {
  allocated_storage            = 20
  apply_immediately            = true
  auto_minor_version_upgrade   = true
  engine_version               = "3.6.1"
  multi_az                     = false
  preferred_maintenance_window = "sun:10:30-sun:14:30"
  publicly_accessible          = false
  replication_instance_class   = "dms.t3.small"
  replication_instance_id      = "dms-replication-instance-tf"
  replication_subnet_group_id  = aws_dms_replication_subnet_group.deburf_sb_group.id

  tags = merge(local.common_tags, {
    Name = "federated-engineers-${var.environment}-${var.team}",
  })

  vpc_security_group_ids = [
    aws_security_group.replication_instance.id
  ]

  depends_on = [
    aws_iam_role_policy_attachment.dms_vpc_role_policy
  ]
}

data "aws_ssm_parameter" "rds_creds" {
  name            = "/production/rds/credentials"
  with_decryption = true
}

locals {
  rds_creds = jsondecode(data.aws_ssm_parameter.rds_creds.value)
}

resource "aws_dms_endpoint" "source" {
  endpoint_id   = "deburf-dms-source-endpoint"
  endpoint_type = "source"
  engine_name   = "postgres"

  username      = local.rds_creds.username
  password      = local.rds_creds.password
  server_name   = local.rds_creds.host
  port          = 5432
  database_name = local.rds_creds.database_name

  ssl_mode = "require"
}

resource "aws_dms_s3_endpoint" "target" {
  endpoint_id   = "deburf-dms-target-endpoint"
  endpoint_type = "target"

  bucket_name   = module.deburf_bucket.bucket_name
  bucket_folder = "raw"

  service_access_role_arn = aws_iam_role.dms_s3_target_role.arn

  data_format             = "parquet"
  compression_type        = "GZIP"
  date_partition_enabled  = false
  date_partition_sequence = "YYYYMMDD"
}

resource "aws_dms_replication_task" "full_load" {
  replication_task_id      = "dms-replication-instance-tf"
  migration_type           = "full-load"
  replication_instance_arn = aws_dms_replication_instance.deburf_dms_ri.replication_instance_arn
  source_endpoint_arn      = aws_dms_endpoint.source.endpoint_arn
  target_endpoint_arn      = aws_dms_s3_endpoint.target.endpoint_arn

  table_mappings = jsonencode({
    rules = [
      {
        "rule-type" = "selection"
        "rule-id"   = "1"
        "rule-name" = "1"
        "object-locator" = {
          "schema-name" = "public"
          "table-name"  = "logistics_routes"
        }
        "rule-action" = "include"
      },
      {
        "rule-type" = "selection"
        "rule-id"   = "2"
        "rule-name" = "2"
        "object-locator" = {
          "schema-name" = "public"
          "table-name"  = "logistics_shipments"
        }
        "rule-action" = "include"
      }
    ]
  })
}

data "aws_route_tables" "private" {
  vpc_id = data.aws_vpc.production.id

  filter {
    name   = "tag:Name"
    values = ["secure-production-private-*"]
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = "data.aws_vpc.production.id"
  service_name      = "com.amazonaws.eu-central-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = data.aws_route_tables.private.ids
}
