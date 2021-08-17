variable "tags" {
  type = map(string)
  description = "Tags to add to resources"
}

variable "external_secrets" {
  type = list(object({
    name: string
    mapping: string
  }))

  description = "List of external secrets that should be loaded in the env"
}

variable "resources_base_name" {
  type = string
  description = "Base name for resources"
}

variable "lambda_execution_role_name" {
  type = string
  description = "Lambda execution role name"
}
