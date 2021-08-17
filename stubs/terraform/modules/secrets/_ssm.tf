data "aws_ssm_parameter" "external" {
  for_each = {for k, v in var.external_secrets : v.name => v}
  name = each.value.name
}

resource "random_password" "app_key" {
  length = 32
  special = true
}

locals {
  ssm_path = "/phl/${var.resources_base_name}"

  secrets = [
    {name: "APP_KEY", value: random_password.app_key.result}
  ]
}

resource "aws_ssm_parameter" "secrets" {
  for_each = {for k, v in local.secrets : v.name => v}
  name = "${local.ssm_path}/${each.value.name}"
  tags = merge(var.tags, {Name: "${local.ssm_path}/${each.value.name}"})
  value = each.value.value
  type = "SecureString"
  key_id = aws_kms_key.secrets.arn
}

resource "aws_ssm_parameter" "external" {
  for_each = {for k, v in var.external_secrets : v.name => v}

  name = "${local.ssm_path}/ext/${each.value.mapping}"
  type = "SecureString"
  value = data.aws_ssm_parameter.external[each.value.name].value
  key_id = aws_kms_key.secrets.arn
}
