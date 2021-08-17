// API G
resource "aws_apigatewayv2_domain_name" "domain" {
  for_each = {for k, d in var.domains : d.domain_name => d}
  domain_name = each.value.domain_name

  domain_name_configuration {
    certificate_arn = each.value.cert_arn
    endpoint_type = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_route53_record" "domain" {
  for_each = {for k, d in var.domains : d.domain_name => d}
  name = each.value.domain_name
  type = "A"
  zone_id = each.value.zone_id

  alias {
    evaluate_target_health = false
    name = aws_apigatewayv2_domain_name.domain[each.key].domain_name_configuration[0].target_domain_name
    zone_id = aws_apigatewayv2_domain_name.domain[each.key].domain_name_configuration[0].hosted_zone_id
  }
}

resource "aws_apigatewayv2_api_mapping" "mapping" {
  for_each = {for k, d in var.domains : d.domain_name => d}
  api_id = aws_apigatewayv2_api.api.id
  stage = aws_apigatewayv2_stage.latest.id
  domain_name = aws_apigatewayv2_domain_name.domain[each.key].domain_name
}
