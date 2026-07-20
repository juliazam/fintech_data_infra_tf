resource "aws_s3_bucket" "raw_data" {
  bucket = "${local.full_name}-raw-data"
}