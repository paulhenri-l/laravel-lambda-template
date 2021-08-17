resource "aws_cloudwatch_log_group" "web" {
  name = "/aws/lambda/${var.resources_base_name}-web"
  tags = merge(var.tags, {Name: "/aws/lambda/${var.resources_base_name}-web"})
  retention_in_days = 30
}

resource "aws_lambda_function" "web" {
  depends_on = [aws_cloudwatch_log_group.web]
  function_name = "${var.resources_base_name}-web"
  tags = merge(var.tags, {Name: "${var.resources_base_name}-web"})
  role = var.lambda_execution_role_arn

  publish = true

  runtime = "provided.al2"
  timeout = 29
  memory_size = var.web_memory_size
  reserved_concurrent_executions = var.web_reserved_concurrent_executions

  vpc_config {
    security_group_ids = var.security_group_ids
    subnet_ids = var.vpc_subnets
  }

  handler = "public/index.php"
  s3_bucket = aws_s3_bucket.code_bucket.id
  s3_key = aws_s3_bucket_object.code.key
  source_code_hash = filebase64sha256(local.code_path)

  layers = [
    "arn:aws:lambda:eu-west-3:209497400698:layer:php-80-fpm:14",
    "arn:aws:lambda:eu-west-3:403367587399:layer:redis-php-80:10",
    "arn:aws:lambda:eu-west-3:580247275435:layer:LambdaInsightsExtension:14",
  ]

  kms_key_arn = var.kms_key_arn
  environment {
    variables = local.env
  }

  tracing_config {
    mode = "Active"
  }
}

resource "aws_lambda_alias" "web" {
  function_name = aws_lambda_function.web.arn
  function_version = aws_lambda_function.web.version
  name = "latest"

  lifecycle {
    ignore_changes = [function_version]
  }
}

// Api Gateway
resource "aws_lambda_permission" "web" {
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.web.arn
  qualifier = aws_lambda_alias.web.name
  principal = "apigateway.amazonaws.com"

  source_arn = "${var.web_api_gateway_execution_arn}/*/*"
}

resource "aws_apigatewayv2_integration" "web" {
  api_id = var.web_api_gateway_id
  integration_uri = aws_lambda_alias.web.invoke_arn
  integration_type = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "web" {
  api_id = var.web_api_gateway_id
  route_key = "$default"
  target = "integrations/${aws_apigatewayv2_integration.web.id}"
}

// Warmer
resource "aws_cloudwatch_event_rule" "warmer" {
  name = "${var.resources_base_name}-warmer"
  tags = merge(var.tags, {Name: "${var.resources_base_name}-warmer"})
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "warmer" {
  arn = aws_lambda_alias.web.arn
  rule = aws_cloudwatch_event_rule.warmer.id

  input_transformer {
    input_template = jsonencode({
      body: "",
      path: "/",
      httpMethod: "GET"
    })
  }
}

resource "aws_lambda_permission" "warmer" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.web.arn
  qualifier = aws_lambda_alias.web.name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.warmer.arn
}
