locals {
  lambda_cwlogs_name = "/aws/lambda/${local.function_name}"
}

#-----------------------------------------
# CloudWatch Logs
#-----------------------------------------
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = local.lambda_cwlogs_name
  retention_in_days = 0

  tags = {
    Name = local.lambda_cwlogs_name
  }
}
