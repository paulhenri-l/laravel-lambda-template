resource "aws_dynamodb_table" "cache" {
  hash_key = "key"
  name = "${var.resources_base_name}-cache"
  billing_mode = "PAY_PER_REQUEST"

  ttl {
    enabled = true
    attribute_name = "expires_at"
  }

  attribute {
    name = "key"
    type = "S"
  }

  tags = merge(var.tags, {Name: "${var.resources_base_name}-cache"})
}

resource "aws_iam_role_policy" "dynamodb" {
  name = "dynamodb"
  role = var.lambda_execution_role_name

  policy = jsonencode({
    Version: "2012-10-17"
    Statement: [
      {
        Effect: "Allow",
        Action: [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ],
        Resource: [
          aws_dynamodb_table.cache.arn,
          "${aws_dynamodb_table.cache.arn}/index/*"
        ]
      }
    ]
  })
}
