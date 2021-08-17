// Network
data "aws_ssm_parameter" "vpc_private_subnets" {
  name = "/phl/infra/vpc_private_subnets"
}

data "aws_ssm_parameter" "lambda_default_sg_id" {
  name = "/phl/infra/lambda_default_sg_id"
}
