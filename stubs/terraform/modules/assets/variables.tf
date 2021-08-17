variable "tags" {
  type = map(string)
  description = "Tags to add to resources"
}

variable "resources_base_name" {
  type = string
  description = "Base name for resources"
}

variable "build_path" {
  type = string
  description = "Path to the build directory"
}
