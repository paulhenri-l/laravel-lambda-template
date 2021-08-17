resource "aws_s3_bucket" "storage_private" {
  bucket = "${var.resources_base_name}-storage-private"
  tags = merge(var.tags, {Name: "${var.resources_base_name}-storage-private"})
  acl = "private"
  force_destroy = true
}
