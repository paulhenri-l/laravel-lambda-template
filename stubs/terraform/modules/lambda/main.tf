data "aws_region" "this" {}
data "aws_caller_identity" "this" {}

locals {
  code_path = "${var.build_path}/code.zip"

  env = merge({
    // APP
    APP_URL: var.app_url
    APP_ENV: var.app_env
    APP_CONFIG_CACHE: "/tmp/storage/bootstrap/cache/config.php"
    SCHEDULE_CACHE_DRIVER: "dynamodb"
    PHL_SSM_SECRETS: jsonencode(var.ssm_secrets)

    // Drivers
    QUEUE_CONNECTION: "sqs"
    CACHE_DRIVER: "dynamodb"
    SESSION_DRIVER: "cookie"
    FILESYSTEM_DRIVER: "s3_private"
    FILESYSTEM_DRIVER_CLOUD: "s3_public"

    // Assets
    ASSET_URL: var.assets_url
    MIX_URL: var.assets_url

    // Storage
    AWS_BUCKET_PRIVATE: var.storage_private_bucket
    AWS_BUCKET_PUBLIC: var.storage_public_bucket

    // Queue
    SQS_QUEUE: var.queue_default_sqs_queue_id

    // Log
    LOG_CHANNEL: "stderr"

    // Dynamo
    DYNAMODB_CACHE_TABLE: var.cache_table_name

    // DB
    DB_CONNECTION: "mysql"
    DB_PORT:3306
    DB_DATABASE: var.resources_base_name

    // Mail

    // Redis
  }, var.env)
}
