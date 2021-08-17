resource "aws_cloudwatch_log_group" "scheduler" {
  name = "/aws/lambda/${var.resources_base_name}-scheduler"
  tags = merge(var.tags, {Name: "/aws/lambda/${var.resources_base_name}-scheduler"})
  retention_in_days = 30
}

resource "aws_lambda_function" "scheduler" {
  depends_on = [aws_cloudwatch_log_group.scheduler]
  function_name = "${var.resources_base_name}-scheduler"
  tags = merge(var.tags, {Name: "${var.resources_base_name}-scheduler"})
  role = var.lambda_execution_role_arn

  publish = true

  runtime = "provided.al2"
  timeout = 60 * 15
  memory_size = var.scheduler_memory_size
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

resource "aws_lambda_alias" "scheduler" {
  function_name = aws_lambda_function.scheduler.arn
  function_version = aws_lambda_function.scheduler.version
  name = "latest"

  lifecycle {
    ignore_changes = [function_version]
  }
}

resource "aws_cloudwatch_event_rule" "scheduler" {
  name = "${var.resources_base_name}-scheduler"
  tags = merge(var.tags, {Name: "${var.resources_base_name}-scheduler"})
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "scheduler" {
  arn = aws_lambda_alias.scheduler.arn
  rule = aws_cloudwatch_event_rule.scheduler.id

  input_transformer {
    input_template = "\"schedule:run\""
  }
}

resource "aws_lambda_permission" "scheduler" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.scheduler.arn
  qualifier = aws_lambda_alias.scheduler.name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.scheduler.arn
}
