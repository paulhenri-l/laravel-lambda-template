resource "aws_s3_bucket" "code_bucket" {
  bucket = "${var.resources_base_name}-code"
  tags = merge(var.tags, {Name: "${var.resources_base_name}-code"})
  acl = "private"
  force_destroy = true
}

resource "aws_s3_bucket_object" "code" {
  bucket = aws_s3_bucket.code_bucket.id
  key = filesha256(local.code_path)
  source = local.code_path
}
