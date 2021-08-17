data "aws_route53_zone" "zone" {
  name = var.zone_name
}

resource "aws_acm_certificate" "domain_cert" {
  domain_name = var.domain_name
  validation_method = "DNS"
  tags = merge(var.tags, {Name: replace(var.domain_name, "*", "wildcard")})
}

resource "aws_route53_record" "alb_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.domain_cert.domain_validation_options : dvo.domain_name => {
      name = dvo.resource_record_name
      record = dvo.resource_record_value
      type = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name = each.value.name
  records = [each.value.record]
  ttl = 60
  type = each.value.type
  zone_id = data.aws_route53_zone.zone.zone_id
}

resource "aws_acm_certificate_validation" "domain_cert" {
  certificate_arn = aws_acm_certificate.domain_cert.arn
  validation_record_fqdns = [
    for record in aws_route53_record.alb_cert_validation : record.fqdn
  ]
}

resource "aws_route53_record" "extra" {
  for_each = {for k, r in var.extra_records : r.name => r}
  name = each.value.name
  records = [each.value.value]
  type = each.value.type
  ttl = 60
  zone_id = data.aws_route53_zone.zone.id
}
