data "aws_caller_identity" "current" {}

resource "aws_iam_role_policy" "secrets" {
  name = "secrets"
  role = var.lambda_execution_role_name

  policy = jsonencode({
    Version: "2012-10-17"
    Statement: [
      {
        Effect: "Allow",
        Action: [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:CreateGrant",
        ],
        Resource: [
          aws_kms_key.lambda.arn,
          aws_kms_key.secrets.arn,
        ]
      },
      {
        Effect: "Allow",
        Action: [
          "ssm:GetParameter",
          "ssm:GetParameters",
        ],
        Resource: concat(
          [for s in aws_ssm_parameter.secrets : s.arn],
          [for s in aws_ssm_parameter.external : s.arn],
        )
      }
    ]
  })
}
