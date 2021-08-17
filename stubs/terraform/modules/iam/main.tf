data "aws_caller_identity" "this" {}

resource "aws_iam_role" "lambda_execution_role" {
  name = "${var.resources_base_name}-execution-role"

  assume_role_policy = jsonencode({
    Version: "2012-10-17"
    Statement: [
      {
        Action: "sts:AssumeRole"
        Effect: "Allow"
        Principal: {
          Service: "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {Name: "${var.resources_base_name}-execution-role"})
}

resource "aws_iam_role_policy" "cloudwatch" {
  name = "cloudwatch"
  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
      {
        Effect: "Allow",
        Action: [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource: [
          "arn:aws:logs:*:${data.aws_caller_identity.this.account_id}:log-group:/aws/lambda/${var.resources_base_name}*",
          "arn:aws:logs:*:${data.aws_caller_identity.this.account_id}:log-group:/aws/lambda/${var.resources_base_name}*:log-stream:*",
          "arn:aws:logs:*:${data.aws_caller_identity.this.account_id}:log-group:/aws/lambda-insights",
          "arn:aws:logs:*:${data.aws_caller_identity.this.account_id}:log-group:/aws/lambda-insights:log-stream:*",
        ]
      },
      {
        Effect: "Allow"
        Action: [
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords",
          "xray:GetSamplingRules",
          "xray:GetSamplingTargets",
          "xray:GetSamplingStatisticSummaries"
        ]
        Resource: "*"
      },
      {
        Effect: "Allow"
        Action: [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:AssignPrivateIpAddresses",
          "ec2:UnassignPrivateIpAddresses"
        ]
        Resource: "*"
      }
    ]
  })
}
