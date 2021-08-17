data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_origin_request_policy" "cors_s3_origin" {
  name = "Managed-CORS-S3Origin"
}

resource "aws_cloudfront_origin_access_identity" "assets" {
  comment = var.resources_base_name
}

resource "aws_cloudfront_distribution" "assets" {
  enabled = true
  price_class = "PriceClass_100"

  origin {
    domain_name = aws_s3_bucket.assets.bucket_domain_name
    origin_id = "${var.resources_base_name}-assets"

    origin_shield {
      enabled = true
      origin_shield_region = "eu-west-1"
    }

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.assets.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods = ["GET", "HEAD"]
    target_origin_id = "${var.resources_base_name}-assets"
    viewer_protocol_policy = "redirect-to-https"

    compress = true
    cache_policy_id = data.aws_cloudfront_cache_policy.caching_optimized.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.cors_s3_origin.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
