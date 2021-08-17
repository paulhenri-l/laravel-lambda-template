resource "aws_s3_bucket" "storage_public" {
  bucket = "${var.resources_base_name}-storage-public"
  tags = merge(var.tags, {Name: "${var.resources_base_name}-storage-public"})
  acl = "public-read"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "storage_public" {
  bucket = aws_s3_bucket.storage_public.id
  policy = jsonencode({
    Version:"2012-10-17",
    Statement:[
      {
        Effect:"Allow",
        Principal: "*",
        Action:["s3:GetObject"],
        Resource:["${aws_s3_bucket.storage_public.arn}/*"]
      }
    ]
  })
}

// Add cloudfront distribution
