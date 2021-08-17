resource "aws_cloudwatch_log_group" "api" {
  name = "${var.resources_base_name}-api-gateway"
  tags = merge(var.tags, {Name: "${var.resources_base_name}-api-gateway"})
  retention_in_days = 7
}

resource "aws_apigatewayv2_api" "api" {
  name = var.resources_base_name
  protocol_type = "HTTP"
  tags = merge(var.tags, {Name: var.resources_base_name})
}

resource "aws_apigatewayv2_stage" "latest" {
  api_id = aws_apigatewayv2_api.api.id
  name = "$default"
  auto_deploy = true

  default_route_settings {
    detailed_metrics_enabled = true
    throttling_burst_limit = var.burst_limit
    throttling_rate_limit = var.rate_limit
  }

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api.arn

    format = jsonencode({
      requestId:"$context.requestId",
      ip: "$context.identity.sourceIp",
      requestTime:"$context.requestTime",
      httpMethod:"$context.httpMethod",
      routeKey:"$context.routeKey",
      status:"$context.status",
      protocol:"$context.protocol",
      responseLength:"$context.responseLength"
    })
  }

  tags = merge(var.tags, {Name: var.resources_base_name})
}
