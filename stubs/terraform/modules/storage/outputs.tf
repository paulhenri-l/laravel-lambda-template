output "public_bucket_id" {
  value = aws_s3_bucket.storage_public.id
}

output "private_bucket_id" {
  value = aws_s3_bucket.storage_private.id
}
