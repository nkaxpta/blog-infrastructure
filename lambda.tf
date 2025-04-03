locals {
  function_name = "${local.name_prefix}-move-s3-function"
}

#-----------------------------------------
# Lambda
#-----------------------------------------
resource "aws_lambda_function" "move_s3" {
  description   = "Artifact move S3 for AWS CLI"
  function_name = local.function_name
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.blog.repository_url}:latest"
  role          = aws_iam_role.lambda_role.arn

  memory_size = 256
  timeout     = 60

  ephemeral_storage {
    size = 512
  }

  logging_config {
    log_format = "Text"
    log_group  = local.lambda_cwlogs_name
  }

  lifecycle {
    ignore_changes = [
      image_uri
    ]
  }

  depends_on = [
    aws_iam_role.lambda_role,
    aws_cloudwatch_log_group.lambda_logs,
    aws_ecr_repository.blog,
    null_resource.docker_build
  ]

  tags = {
    Name = local.function_name
  }
}

# EventBridgeからのトリガー設定
resource "aws_lambda_permission" "hook_eventbridge" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.move_s3.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.to_lambda.arn
}
