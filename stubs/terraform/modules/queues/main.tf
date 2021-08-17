resource "aws_sqs_queue" "default_jobs" {
  name = "${var.resources_base_name}-default-jobs"
  tags = merge(var.tags, {Name: "${var.resources_base_name}-default-jobs"})
  max_message_size = 262144 // 256 KiB

  delay_seconds = 0
  visibility_timeout_seconds = (60 * 15) + 1 // Lambda timeout +1 sec
  message_retention_seconds = ((60 * 60) * 24) * 7 // 7 days
  receive_wait_time_seconds = 10

  redrive_policy = jsonencode({
    deadLetterTargetArn: aws_sqs_queue.default_failed_jobs.arn
    maxReceiveCount: 3
  })
}

resource "aws_sqs_queue" "default_failed_jobs" {
  name = "${var.resources_base_name}-default-failed-jobs"
  tags = merge(var.tags, {Name: "${var.resources_base_name}-default-failed-jobs"})
  max_message_size = 262144 // 256 KiB

  delay_seconds = 0
  visibility_timeout_seconds = (60 * 15) + 1 // Lambda timeout +1 sec
  message_retention_seconds = ((60 * 60) * 24) * 14 // 14 days
  receive_wait_time_seconds = 10
}

resource "aws_iam_role_policy" "queues" {
  name = "queues"
  role = var.lambda_execution_role_name

  policy = jsonencode({
    Version: "2012-10-17"
    Statement: [
      {
        Effect: "Allow",
        Action: [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ChangeMessageVisibility",
        ],
        Resource: [
          aws_sqs_queue.default_jobs.arn,
          aws_sqs_queue.default_failed_jobs.arn,
        ]
      }
    ]
  })
}
