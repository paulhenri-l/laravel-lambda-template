resource "aws_codedeploy_app" "app" {
  name = var.resources_base_name
  compute_platform = "Lambda"
  tags = merge(var.tags, {Name: var.resources_base_name})
}

resource "aws_iam_role" "codedeploy" {
  name = "${var.resources_base_name}-codedeploy"

  assume_role_policy = jsonencode({
    Version: "2012-10-17"
    Statement: [
      {
        Action: "sts:AssumeRole"
        Effect: "Allow"
        Principal: {
          Service: "codedeploy.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name: "${var.resources_base_name}-codedeploy"
  })
}

resource "aws_iam_role_policy_attachment" "codedeploy" {
  role = aws_iam_role.codedeploy.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRoleForLambda"
}

// Groups
resource "aws_codedeploy_deployment_group" "artisan" {
  app_name = var.resources_base_name
  deployment_group_name = "artisan"
  service_role_arn = aws_iam_role.codedeploy.arn
  deployment_config_name = "CodeDeployDefault.LambdaAllAtOnce"

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type = "BLUE_GREEN"
  }

  auto_rollback_configuration {
    enabled = true
    events = ["DEPLOYMENT_STOP_ON_ALARM"]
  }

  tags = merge(var.tags, {Name: "artisan"})
}

resource "aws_codedeploy_deployment_group" "queue" {
  app_name = var.resources_base_name
  deployment_group_name = "queue"
  service_role_arn = aws_iam_role.codedeploy.arn
  deployment_config_name = "CodeDeployDefault.LambdaAllAtOnce"

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type = "BLUE_GREEN"
  }

  auto_rollback_configuration {
    enabled = true
    events = ["DEPLOYMENT_STOP_ON_ALARM"]
  }

  tags = merge(var.tags, {Name: "queue"})
}

resource "aws_codedeploy_deployment_group" "scheduler" {
  app_name = var.resources_base_name
  deployment_group_name = "scheduler"
  service_role_arn = aws_iam_role.codedeploy.arn
  deployment_config_name = "CodeDeployDefault.LambdaAllAtOnce"

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type = "BLUE_GREEN"
  }

  auto_rollback_configuration {
    enabled = true
    events = ["DEPLOYMENT_STOP_ON_ALARM"]
  }

  tags = merge(var.tags, {Name: "scheduler"})
}

resource "aws_codedeploy_deployment_group" "web" {
  app_name = var.resources_base_name
  deployment_group_name = "web"
  service_role_arn = aws_iam_role.codedeploy.arn
  deployment_config_name = "CodeDeployDefault.LambdaAllAtOnce"

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type = "BLUE_GREEN"
  }

  auto_rollback_configuration {
    enabled = true
    events = ["DEPLOYMENT_STOP_ON_ALARM"]
  }

  tags = merge(var.tags, {Name: "web"})
}
