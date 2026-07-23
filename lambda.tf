data "archive_file" "etl_lambda_zip" {
  type        = "zip"
  source_file = "lambda/handler.py"
  output_path = "lambda/handler.zip"
}

resource "aws_lambda_function" "etl_processor" {
  function_name = "${local.full_name}-etl-processor"
  role          = aws_iam_role.lambda_role.arn
  handler       = "handler.handler"
  runtime       = "python3.13"

  filename         = data.archive_file.etl_lambda_zip.output_path
  source_code_hash = data.archive_file.etl_lambda_zip.output_base64sha256
}
