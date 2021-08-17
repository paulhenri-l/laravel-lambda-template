resource "aws_cloudwatch_log_group" "artisan" {
  name = "/aws/lambda/${var.resources_base_name}-artisan"
  tags = merge(var.tags, {Name: "/aws/lambda/${var.resources_base_name}-artisan"})
  retention_in_days = 30
}

resource "aws_lambda_function" "artisan" {
  depends_on = [aws_cloudwatch_log_group.artisan]
  function_name = "${var.resources_base_name}-artisan"
  tags = merge(var.tags, {Name: "${var.resources_base_name}-artisan"})
  role = var.lambda_execution_role_arn

  publish = true

  runtime = "provided.al2"
  timeout = 60 * 15
  memory_size = var.artisan_memory_size
  reserved_concurrent_executions = 1

  vpc_config {
    security_group_ids = var.security_group_ids
    subnet_ids = var.vpc_subnets
  }

  handler = "artisan"
  s3_bucket = aws_s3_bucket.code_bucket.id
  s3_key = aws_s3_bucket_object.code.key
  source_code_hash = filebase64sha256(local.code_path)

  layers = [
    "arn:aws:lambda:eu-west-3:209497400698:layer:php-80:14",
    "arn:aws:lambda:eu-west-3:403367587399:layer:redis-php-80:10",
    "arn:aws:lambda:eu-west-3:209497400698:layer:console:39",
    "arn:aws:lambda:eu-west-3:580247275435:layer:LambdaInsightsExtension:14",
  ]

  kms_key_arn = var.kms_key_arn
  environment {
    variables = merge(local.env, {APP_RUNNING_IN_CONSOLE: "true"})
  }

  tracing_config {
    mode = "Active"
  }
}

resource "aws_lambda_alias" "artisan" {
  function_name = aws_lambda_function.artisan.arn
  function_version = aws_lambda_function.artisan.version
  name = "latest"

  lifecycle {
    ignore_changes = [function_version]
  }
}
