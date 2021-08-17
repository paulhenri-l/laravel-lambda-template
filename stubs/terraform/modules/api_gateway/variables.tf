variable "tags" {
  type = map(string)
  description = "Tags to add to resources"
}

variable "resources_base_name" {
  type = string
  description = "Base name for resources"
}

// Api
variable "burst_limit" {
  type = number
  description = "API Throttling config"
}

variable "rate_limit" {
  type = number
  description = "API Throttling config"
}

// Domains
variable "domains" {
  type = map(object({
    cert_arn: string
    domain_name: string
    zone_id: string
  }))
}
