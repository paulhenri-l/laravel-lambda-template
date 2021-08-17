variable "tags" {
  type = map(string)
  description = "Tags to add to resources"
}

variable "resources_base_name" {
  type = string
  description = "Base name for resources"
}

variable "lambda_execution_role_name" {
  type = string
  description = "Lambda execution role name"
}
