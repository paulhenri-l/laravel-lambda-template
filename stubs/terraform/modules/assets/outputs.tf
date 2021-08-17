output "assets_url" {
  value = "https://${aws_cloudfront_distribution.assets.domain_name}/${local.assets_hash}"
}
