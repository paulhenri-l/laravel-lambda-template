resource "aws_iam_role_policy" "storage" {
  name = "storage"
  role = var.lambda_execution_role_name

  policy = jsonencode({
    Version: "2012-10-17"
    Statement: [
      {
        Effect: "Allow",
        Action: [
          "s3:*",
        ],
        Resource: [
          aws_s3_bucket.storage_public.arn,
          "${aws_s3_bucket.storage_public.arn}/*",
          aws_s3_bucket.storage_private.arn,
          "${aws_s3_bucket.storage_private.arn}/*",
        ]
      }
    ]
  })
}
