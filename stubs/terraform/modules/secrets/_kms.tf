resource "aws_kms_key" "secrets" {
  description = "${var.resources_base_name}-secrets-key"
  tags = merge(var.tags, {Name: "${var.resources_base_name}-secrets-key"})
}

resource "aws_kms_key" "lambda" {
  description = "${var.resources_base_name}-lambda-key"
  tags = merge(var.tags, {Name: "${var.resources_base_name}-lambda-key"})
}
