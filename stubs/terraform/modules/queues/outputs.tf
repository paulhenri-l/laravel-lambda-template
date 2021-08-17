output "default_queue_id" {
  value = aws_sqs_queue.default_jobs.id
}

output "default_queue_arn" {
  value = aws_sqs_queue.default_jobs.arn
}

output "default_queue_name" {
  value = aws_sqs_queue.default_jobs.name
}
