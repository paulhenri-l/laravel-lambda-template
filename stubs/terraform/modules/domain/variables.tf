variable "tags" {
  type = map(string)
  description = "Tags to add to resources"
}

variable "domain_name" {
  type = string
  description = "Domain name to manage"
}

variable "zone_name" {
  type = string
  description = "Zone to use"
}

variable "extra_records" {
  type = list(object({
    type: string
    name: string
    value: string
  }))

  default = []

  description = "Extra records to register"
}
