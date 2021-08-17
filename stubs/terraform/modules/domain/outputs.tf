output "cert_arn" {
  value = aws_acm_certificate.domain_cert.arn
}

output "domain_name" {
  value = var.domain_name
}

output "zone_id" {
  value = data.aws_route53_zone.zone.id
}
