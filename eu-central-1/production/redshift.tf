resource "aws_redshift_cluster" "spreekauf_analytics_db_cluster" {
  cluster_identifier           = "spreekauf-redshift-cluster"
  database_name                = "spreekaufdb"
  master_username              = "spreekauf_redshift"
  master_password              = aws_ssm_parameter.spreekauf_redshift_password.value
  node_type                    = "ra3.large"
  cluster_type                 = "single-node"
  cluster_subnet_group_name    = aws_redshift_subnet_group.spreekauf_redshift_subnet_group.name
  vpc_security_group_ids       = [aws_security_group.spreekauf_db_security_group.id]
  publicly_accessible          = true
  cluster_parameter_group_name = aws_redshift_parameter_group.spreekauf_db_wlm.name
  skip_final_snapshot          = true
}


resource "aws_redshift_parameter_group" "spreekauf_db_wlm" {
  name   = "spreekauf-analytics-wlm"
  family = "redshift-1.0"

  parameter {
    name = "wlm_json_configuration"
    value = jsonencode([
      {

        user_group            = ["etl_group"]
        query_concurrency     = 5
        memory_percent_to_use = 20
        concurrency_scaling   = "off"
        rules = [
          {
            rule_name = "abort_etl_scan_over_2tb"
            predicate = [
              { metric_name = "query_blocks_read", operator = ">", value = 1048575 }
            ]
            action = "abort"
          },
          {
            rule_name = "downgrade_etl_long_running"
            predicate = [
              { metric_name = "query_cpu_usage_percent", operator = ">", value = 80 },
              { metric_name = "query_execution_time", operator = ">", value = 1200 }
            ]
            action = "hop"
          }
        ]
      },
      {

        user_group            = ["ds_group"]
        query_concurrency     = 5
        memory_percent_to_use = 30
        concurrency_scaling   = "off"
        rules = [
          {
            rule_name = "abort_DS_scan_over_2tb"
            predicate = [
              { metric_name = "query_blocks_read", operator = ">", value = 1048575 }
            ]
            action = "abort"
          },
          {
            rule_name = "downgrade_ds_long_running"
            predicate = [
              { metric_name = "query_cpu_usage_percent", operator = ">", value = 80 },
              { metric_name = "query_execution_time", operator = ">", value = 1200 }
            ]
            action = "hop"
          }
        ]
      },
      {

        user_group            = ["bi_group"]
        query_concurrency     = 2
        memory_percent_to_use = 45
        concurrency_scaling   = "off"
        rules = [
          {
            rule_name = "downgrade_bi_long_running"
            predicate = [
              { metric_name = "query_execution_time", operator = ">", value = 5 }
            ]
            action = "abort"
          },
        ]
      },

      {
        query_concurrency     = 2
        memory_percent_to_use = 5
        concurrency_scaling   = "off"
        rules = [
          {
            rule_name = "abort_def_scan_over_2tb"
            predicate = [
              { metric_name = "query_blocks_read", operator = ">", value = 1048575 }
            ]
            action = "abort"
          },
          {
            rule_name = "downgrade_def_long_running"
            predicate = [
              { metric_name = "query_cpu_usage_percent", operator = ">", value = 80 },
              { metric_name = "query_execution_time", operator = ">", value = 1200 }
            ]
            action = "ab"
          }
        ]
      },


      {
        short_query_queue = true
      }
    ])
  }
}



