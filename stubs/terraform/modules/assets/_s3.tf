locals {
  assets_hash = filesha256("${var.build_path}/assets.zip")
}

resource "aws_s3_bucket" "assets" {
  bucket = "${var.resources_base_name}-assets"
  tags = merge(var.tags, {Name: "${var.resources_base_name}-assets"})
  acl = "private"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "assets" {
  bucket = aws_s3_bucket.assets.id
  policy = jsonencode({
    Version:"2012-10-17",
    Statement:[
      {
        Effect:"Allow",
        Action:"s3:GetObject",
        Principal: "*",
        Resource: "${aws_s3_bucket.assets.arn}/*"
      },
      {
        Effect: "Allow"
        Action: "s3:GetObject"
        Principal: {
          AWS: aws_cloudfront_origin_access_identity.assets.iam_arn
        }
        Resource: "${aws_s3_bucket.assets.arn}/*"
      }
    ]
  })
}

resource "null_resource" "upload" {
  triggers = {
    assets_hash: local.assets_hash
  }

  provisioner "local-exec" {
    command = <<CMD
    aws s3 sync "${var.build_path}/assets" "s3://${aws_s3_bucket.assets.id}/${local.assets_hash}"
CMD
  }
}
