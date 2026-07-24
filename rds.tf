resource "aws_db_instance" "etl_db" {
    identifier = "${local.full_name}-db"
    engine = "postgres"
    engine_version = "16"
    instance_class = "db.t3.micro"

    allocated_storage = 20
    max_allocated_storage = 0

    db_name  = "etl_processed"
    username = "etl_admin"
    password = var.db_password

    skip_final_snapshot = true
}