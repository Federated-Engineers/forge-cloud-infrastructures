resource "aws_glue_catalog_database" "moda_milano" {
  name        = "moda_milano_catalog"
  description = "Data catalog for Moda Milano e-commerce data"
  tags = {
    environment = "production"
    team        = "forge"
    region      = var.region
    service     = "athena"
  }
}


resource "aws_glue_catalog_table" "fulfillments_table" {
  name          = "fulfillments"
  database_name = aws_glue_catalog_database.moda_milano.name
  description   = "Order fulfillment data"

  table_type = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL              = "TRUE"
    "parquet.compression" = "SNAPPY"
  }

  partition_keys {
    name = "year"
    type = "int"
  }

  partition_keys {
    name = "month"
    type = "int"
  }

  partition_keys {
    name = "day"
    type = "int"
  }


  storage_descriptor {
    location      = "s3://federated-engineers-staging-forge-datalake/moda-milano/fulfillments/" #test loc
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      name                  = "fulfillments-parquet-serde"
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"

      parameters = {
        "serialization.format" = "1"
      }
    }

    columns {
      name = "wemalo_id"
      type = "string"
    }

    columns {
      name = "external_order_reference"
      type = "string"
    }

    columns {
      name = "sku"
      type = "string"
    }

    columns {
      name = "warehouse_location"
      type = "string"
    }

    columns {
      name = "fulfillment_status"
      type = "string"
    }

    columns {
      name = "carrier"
      type = "string"
    }

    columns {
      name = "tracking_number"
      type = "string"
    }

    columns {
      name = "fulfilled_at"
      type = "timestamp"
    }


  }
}


resource "aws_glue_catalog_table" "products_table" {
  name          = "products"
  database_name = aws_glue_catalog_database.moda_milano.name
  description   = "products data"

  table_type = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL              = "TRUE"
    "parquet.compression" = "SNAPPY"
  }


  storage_descriptor {
    location      = "s3://federated-engineers-staging-forge-datalake/moda-milano/products/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      name                  = "products-parquet-serde"
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"

      parameters = {
        "serialization.format" = "1"
      }
    }

    columns {
      name = "product_id"
      type = "string"
    }


    columns {
      name = "sku"
      type = "string"
    }

    columns {
      name = "name"
      type = "string"
    }

    columns {
      name = "category"
      type = "string"
    }

    columns {
      name = "base_price"
      type = "decimal(10,2)"
    }

    columns {
      name = "created_at"
      type = "timestamp"
    }


  }
}


resource "aws_glue_catalog_table" "orders_table" {
  name          = "orders"
  database_name = aws_glue_catalog_database.moda_milano.name
  description   = "Order transaction data"

  table_type = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL              = "TRUE"
    "parquet.compression" = "SNAPPY"
  }

  partition_keys {
    name = "year"
    type = "int"
  }

  partition_keys {
    name = "month"
    type = "int"
  }

  partition_keys {
    name = "day"
    type = "int"
  }


  storage_descriptor {
    location      = "s3://federated-engineers-staging-forge-datalake/moda-milano/orders/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      name                  = "orders-parquet-serde"
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"

      parameters = {
        "serialization.format" = "1"
      }
    }

    columns {
      name = "order_id"
      type = "string"
    }

    columns {
      name = "product_id"
      type = "string"
    }

    columns {
      name = "sku"
      type = "string"
    }

    columns {
      name = "customer_id"
      type = "string"
    }

    columns {
      name = "quantity"
      type = "int"
    }

    columns {
      name = "total_amount"
      type = "decimal(10,2)"
    }

    columns {
      name = "order_status"
      type = "string"
    }

    columns {
      name = "ordered_at"
      type = "timestamp"
    }


  }
}

