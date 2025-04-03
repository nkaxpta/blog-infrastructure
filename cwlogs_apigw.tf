locals {
  apigw_cwlogs_name = "/aws/apigateway/${local.api_name}"
}

#-----------------------------------------
# CloudWatch Logs
#-----------------------------------------
resource "aws_cloudwatch_log_group" "apigw_logs" {
  name              = local.apigw_cwlogs_name
  retention_in_days = 0

  tags = {
    Name = local.apigw_cwlogs_name
  }
}
