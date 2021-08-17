variable "domains" {
  type = list(object({
    name: string
    zone: string
    extra_records: list(object({
      type: string
      name: string
      value: string
    }))
  }))

  default = [
    {
      name: "stub-project-name.staging.phl.tools",
      zone: "phl.tools",
      extra_records: []
    },

    {
      name: "*.stub-project-name.staging.phl.tools",
      zone: "phl.tools",
      extra_records: []
    },
  ]
}

variable "app_env" {
  type = string
  default = "production"
}
