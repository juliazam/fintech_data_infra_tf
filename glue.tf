resource "aws_glue_catalog_database" "etl_catalog" {
  name       = "${replace(local.full_name, "-", "_")}_catalog"
  provider   = aws.glue_workaround
  catalog_id = "000000000000"
}

resource "aws_glue_catalog_table" "raw_transactions" {
  name          = "raw_transactions"
  provider      = aws.glue_workaround
  database_name = aws_glue_catalog_database.etl_catalog.name

  storage_descriptor {
    location      = "s3://${module.raw_data.bucket_id}/transactions/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    columns {
      name = "transaction_id"
      type = "string"
    }
    columns {
      name = "amount"
      type = "double"
    }
    columns {
      name = "timestamp"
      type = "string"
    }
  }
}
