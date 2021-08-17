output "lambda_kms_key_arn" {
  value = aws_kms_key.lambda.arn
}

// Ssm
output "ssm_secrets" {
  value = concat(
    [for s in aws_ssm_parameter.secrets : "${s.name}:${s.version}"],
    [for s in aws_ssm_parameter.external : "${s.name}:${s.version}"],
  )
}
