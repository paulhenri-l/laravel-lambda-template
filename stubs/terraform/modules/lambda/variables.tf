variable "tags" {
  type = map(string)
  description = "Tags to add to resources"
}

variable "resources_base_name" {
  type = string
  description = "Base name for resources"
}

variable "lambda_execution_role_arn" {
  type = string
  description = "Lambda execution role arn"
}

// General
variable "build_path" {
  type = string
  description = "Path to the build directory"
}

variable "app_url" {
  type = string
  description = "App main url"
}

variable "app_env" {
  type = string
  description = "App environement"
}

variable "env" {
  type = map(string)
  description = "Env vars"
}

variable "kms_key_arn" {
  type = string
  description = "ARN of the KMS key to use for lambda"
}

variable "ssm_secrets" {
  type = list(string)
  description = "List of ssm secrets the app should load"
}

// Network
variable "vpc_subnets" {
  type = list(string)
  description = "VPC Subnets in which to add the lambdas"
  default = []
}

variable "security_group_ids" {
  type = list(string)
  description = "Security groups to use when using a vpc"
  default = []
}

// Web
variable "web_api_gateway_id" {
  type = string
  description = "API Gateway ID"
}

variable "web_api_gateway_execution_arn" {
  type = string
  description = "API Gateway execution arn"
}

variable "web_memory_size" {
  type = number
  description = "Memory size for the web lambda"
}

variable "web_reserved_concurrent_executions" {
  type = number
  description = "Maximum number of web workers"
}

// Scheduler
variable "scheduler_memory_size" {
  type = number
  description = "Memory size for the scheduler lambda"
}

// Artisan
variable "artisan_memory_size" {
  type = number
  description = "Memory size for the artisan lambda"
}

// Queue
variable "queue_memory_size" {
  type = number
  description = "Memory size for the queue lambda"
}

variable "queue_default_sqs_queue_arn" {
  type = string
  description = "SQS default queue arn"
}

variable "queue_default_sqs_queue_id" {
  type = string
  description = "SQS default queue id"
}

variable "queue_reserved_concurrent_executions" {
  type = number
  description = "Maximum number of queue workers"
}

// Cache
variable "cache_table_name" {
  type = string
  description = "Cache table name"
}

// Assets
variable "assets_url" {
  type = string
  description = "Url where assets are stored"
}

// Storage
variable "storage_private_bucket" {
  type = string
  description = "Private storage bucket id"
}

variable "storage_public_bucket" {
  type = string
  description = "Public storage bucket id"
}
