terraform {
  backend "s3" {
    bucket="phl-terraform-state"
    region="eu-west-3"
    key="phl-lara-base-serverless-tf"
    dynamodb_table="terraform-lock"
    profile="default"
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}

provider "aws" {
  region = "eu-west-3"
}

locals {
  tags = {
    Project = "phl"
    Component = "phl-stub-project-name-${terraform.workspace}"
  }

  resources_base_name = "phl-stub-project-name-${terraform.workspace}"
  build_path = "${path.root}/../.build"
}

// Base resources
module "domains" {
  for_each = {for k, d in var.domains : d.name => d}
  source = "./modules/domain"
  tags = local.tags

  domain_name = each.value.name
  zone_name = each.value.zone
  extra_records = each.value.extra_records
}

module "iam" {
  source = "./modules/iam"
  tags = local.tags
  resources_base_name = local.resources_base_name
}

module "api_gateway" {
  source = "./modules/api_gateway"
  tags = local.tags
  resources_base_name = local.resources_base_name

  domains = module.domains

  burst_limit = 10
  rate_limit = 10
}

// Support resources
module "assets" {
  source = "./modules/assets"
  tags = local.tags
  resources_base_name = local.resources_base_name
  build_path = local.build_path
}

module "dynamodb" {
  source = "./modules/dynamodb"
  tags = local.tags
  resources_base_name = local.resources_base_name
  lambda_execution_role_name = module.iam.lambda_execution_role_name
}

module "queues" {
  source = "./modules/queues"
  tags = local.tags
  resources_base_name = local.resources_base_name
  lambda_execution_role_name = module.iam.lambda_execution_role_name
}

module "storage" {
  source = "./modules/storage"
  tags = local.tags
  resources_base_name = local.resources_base_name
  lambda_execution_role_name = module.iam.lambda_execution_role_name
}

module "secrets" {
  source = "./modules/secrets"
  resources_base_name = local.resources_base_name
  tags = local.tags
  lambda_execution_role_name = module.iam.lambda_execution_role_name

  external_secrets = [
    {name: "/phl/infra/rds_main_primary", mapping: "DB_HOST"},
    {name: "/phl/infra/rds_main_username", mapping: "DB_USERNAME"},
    {name: "/phl/infra/rds_main_password", mapping: "DB_PASSWORD"},
  ]
}

// App resources
resource "null_resource" "wait" {
  depends_on = [
    module.api_gateway,
    module.assets,
    module.domains,
    module.dynamodb,
    module.iam,
    module.queues,
    module.storage,
    module.secrets,
  ]
}

module "lambda" {
  depends_on = [null_resource.wait]
  source = "./modules/lambda"
  tags = local.tags
  resources_base_name = local.resources_base_name
  build_path = local.build_path

  lambda_execution_role_arn = module.iam.lambda_execution_role_arn
  kms_key_arn = module.secrets.lambda_kms_key_arn
  ssm_secrets = module.secrets.ssm_secrets
  app_url = var.domains[0].name
  app_env = var.app_env
  env = {}

  // Network
  vpc_subnets = split(",", data.aws_ssm_parameter.vpc_private_subnets.value)
  security_group_ids = [data.aws_ssm_parameter.lambda_default_sg_id.value]

  // Web
  web_memory_size = 1024
  web_api_gateway_id = module.api_gateway.api_id
  web_api_gateway_execution_arn = module.api_gateway.api_execution_arn
  web_reserved_concurrent_executions = 10

  // Queue
  queue_memory_size = 1024
  queue_reserved_concurrent_executions = 10
  queue_default_sqs_queue_id = module.queues.default_queue_id
  queue_default_sqs_queue_arn = module.queues.default_queue_arn

  // Scheduler
  scheduler_memory_size = 1024

  // Artisan
  artisan_memory_size = 1024

  // Cache
  cache_table_name = module.dynamodb.cache_table_name

  // Assets
  assets_url = module.assets.assets_url

  // Storage
  storage_private_bucket = module.storage.private_bucket_id
  storage_public_bucket = module.storage.public_bucket_id
}
