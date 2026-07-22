resource "aws_s3_bucket" "state_bucket" {
  bucket = "${local.full_name}-tfstate"
}

module "raw_data" {
  source = "./modules/s3"
  bucket_name = "${local.full_name}-raw-data"
}