// Prepare deployment
resource "null_resource" "pre_deploy" {
  depends_on = [
    aws_lambda_function.artisan,
    aws_lambda_alias.queue,
    aws_lambda_alias.scheduler,
    aws_lambda_function.web,
  ]

  triggers = {
    artisan: aws_lambda_function.artisan.version
    queue: aws_lambda_function.queue.version
    scheduler: aws_lambda_function.scheduler.version
    web: aws_lambda_function.web.version
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command = <<CMD
#!/bin/bash
php ${path.root}/../vendor/bin/bref cli \
    --region ${data.aws_region.this.name} \
    ${aws_lambda_function.artisan.arn}:${aws_lambda_function.artisan.version} \
    -- ecs:pre-deploy
CMD
  }
}

// Deploy support services
module "deploy_artisan" {
  depends_on = [null_resource.pre_deploy]
  source = "terraform-aws-modules/lambda/aws//modules/deploy"

  alias_name = aws_lambda_alias.artisan.name
  function_name = aws_lambda_function.artisan.function_name

  target_version = aws_lambda_function.artisan.version

  create_codedeploy_role = false
  codedeploy_role_name = aws_iam_role.codedeploy.name

  create_app = false
  app_name = aws_codedeploy_app.app.name

  create_deployment_group = false
  deployment_group_name = aws_codedeploy_deployment_group.artisan.deployment_group_name

  create_deployment = true
  wait_deployment_completion = true
}

module "deploy_queue" {
  depends_on = [null_resource.pre_deploy]
  source = "terraform-aws-modules/lambda/aws//modules/deploy"

  alias_name = aws_lambda_alias.queue.name
  function_name = aws_lambda_function.queue.function_name

  target_version = aws_lambda_function.queue.version

  create_codedeploy_role = false
  codedeploy_role_name = aws_iam_role.codedeploy.name

  create_app = false
  app_name = aws_codedeploy_app.app.name

  create_deployment_group = false
  deployment_group_name = aws_codedeploy_deployment_group.queue.deployment_group_name

  create_deployment = true
  wait_deployment_completion = true
}

// Deploy work services
module "deploy_scheduler" {
  depends_on = [module.deploy_queue, module.deploy_artisan]
  source = "terraform-aws-modules/lambda/aws//modules/deploy"

  alias_name = aws_lambda_alias.scheduler.name
  function_name = aws_lambda_function.scheduler.function_name

  target_version = aws_lambda_function.scheduler.version

  create_codedeploy_role = false
  codedeploy_role_name = aws_iam_role.codedeploy.name

  create_app = false
  app_name = aws_codedeploy_app.app.name

  create_deployment_group = false
  deployment_group_name = aws_codedeploy_deployment_group.scheduler.deployment_group_name

  create_deployment = true
  wait_deployment_completion = true
}

module "deploy_web" {
  depends_on = [module.deploy_queue, module.deploy_artisan]
  source = "terraform-aws-modules/lambda/aws//modules/deploy"

  alias_name = aws_lambda_alias.web.name
  function_name = aws_lambda_function.web.function_name

  target_version = aws_lambda_function.web.version

  create_codedeploy_role = false
  codedeploy_role_name = aws_iam_role.codedeploy.name

  create_app = false
  app_name = aws_codedeploy_app.app.name

  create_deployment_group = false
  deployment_group_name = aws_codedeploy_deployment_group.web.deployment_group_name

  create_deployment = true
  wait_deployment_completion = true
}

// Finish deployment
resource "null_resource" "post_deploy" {
  depends_on = [
    module.deploy_artisan,
    module.deploy_queue,
    module.deploy_scheduler,
    module.deploy_web,
  ]

  triggers = {
    artisan: module.deploy_artisan.appspec_sha256
    queue: module.deploy_queue.appspec_sha256
    scheduler: module.deploy_scheduler.appspec_sha256
    web: module.deploy_web.appspec_sha256
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command = <<CMD
#!/bin/bash
php ${path.root}/../vendor/bin/bref cli \
    --region ${data.aws_region.this.name} \
    ${aws_lambda_function.artisan.arn}:${aws_lambda_function.artisan.version} \
    -- ecs:post-deploy
CMD
  }
}
