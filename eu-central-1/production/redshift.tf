resource "aws_redshift_cluster" "spreekauf_analytics_db_cluster" {
  cluster_identifier        = "spreekauf-redshift-cluster"
  database_name             = "spreekaufdb"
  master_username           = "spreekauf_redshift"
  node_type                 = "ra3.large"
  cluster_type              = "single-node"
  cluster_subnet_group_name = "forge_spreekauf_analytics_redshift_subnet_group"
  vpc_security_group_ids    = [aws_security_group.spreekauf_db_security_group.id]
  publicly_accessible       = false
  manage_master_password    = true
  cluster_parameter_group_name = aws_redshift_parameter_group.spreekauf_db_wlm.name
}


resource "aws_redshift_parameter_group" "spreekauf_db_wlm" {
  name   = "spreekauf-analytics-wlm"
  family = "redshift-1.0"

  parameter {
    name  = "wlm_json_configuration"
    value = jsonencode([
      {

        query_group           = ["etl"]
        query_concurrency     = 5
        memory_percent_to_use = 20
        concurrency_scaling   = "off"
        rules = [
          {
            rule_name = "abort_scan_over_2tb"
            predicate = [
              { metric_name = "query_blocks_read", operator = ">", value = 2097152 }
            ]
            action = "abort"
          },
          {
            rule_name = "downgrade_high_cpu_long_running"
            predicate = [
              { metric_name = "query_cpu_usage_percent", operator = ">", value = 80 },
              { metric_name = "query_execution_time", operator = ">", value = 1200 }
            ]
            action = "hop"
          }
        ]
      },
      {

        query_group           = ["data_science"]
        query_concurrency     = 5
        memory_percent_to_use = 30
        concurrency_scaling   = "off"
        rules = [
          {
            rule_name = "abort_scan_over_2tb"
            predicate = [
              { metric_name = "query_blocks_read", operator = ">", value = 2097152 }
            ]
            action = "abort"
          },
          {
            rule_name = "downgrade_high_cpu_long_running"
            predicate = [
              { metric_name = "query_cpu_usage_percent", operator = ">", value = 80 },
              { metric_name = "query_execution_time", operator = ">", value = 1200 }
            ]
            action = "hop"
          }
        ]
      },
      {
        short_query_queue = true
      }
    ])
  }
}



