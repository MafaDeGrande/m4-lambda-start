locals {
  name = "${var.name}-${var.env}"
  tags = {
    Name = var.name
    Env  = var.env
  }
  handler = var.handler
  path = var.path
  key = var.key
}
resource "aws_s3_bucket" "lambda_bucket" {
  bucket        = var.bucket_name
  force_destroy = true
}

data "archive_file" "lambda_hello_world" {
  type = "zip"

  source_dir  = local.path
  output_path = "${local.path}/${local.key}"
}

resource "aws_s3_object" "lambda_hello_world" {
  bucket = aws_s3_bucket.lambda_bucket.id 
  key = local.key
  source = data.archive_file.lambda_hello_world.output_path
  etag = filemd5(data.archive_file.lambda_hello_world.output_path)
}

resource "aws_lambda_function" "hello_world" {
  function_name = local.name

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key = aws_s3_object.lambda_hello_world.key

  runtime = "provided.al2"
  handler = local.handler

  source_code_hash = data.archive_file.lambda_hello_world.output_base64sha256

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "hello_world" { 
  name = "/aws/lambda/${local.name}"
  retention_in_days = 7
}

resource "aws_iam_role" "lambda_exec" {
  name = local.name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
