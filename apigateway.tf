locals {
  api_name       = "${local.name_prefix}-apigw-microcms"
  api_stage_name = "${local.name_prefix}-apigw-stage-microcms"
}

#-----------------------------------------
# API Gateway
#-----------------------------------------
resource "aws_apigatewayv2_api" "microcms" {
  name          = local.api_name
  protocol_type = "HTTP"

  tags = {
    Name = local.api_name
  }
}

resource "aws_apigatewayv2_route" "microcms" {
  api_id    = aws_apigatewayv2_api.microcms.id
  route_key = "POST /blog"
  target    = "integrations/${aws_apigatewayv2_integration.microcms.id}"
}

resource "aws_apigatewayv2_integration" "microcms" {
  api_id              = aws_apigatewayv2_api.microcms.id
  connection_type     = "INTERNET"
  integration_type    = "AWS_PROXY"
  integration_subtype = "EventBridge-PutEvents"
  credentials_arn     = aws_iam_role.apigw_role.arn

  # https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-develop-integrations-aws-services-reference.html
  request_parameters = {
    "Detail"     = "$request.body.contents"
    "DetailType" = "$request.body.api"
    "Source"     = "$request.body.service"
  }
}

resource "aws_apigatewayv2_stage" "microcms" {
  name        = local.api_stage_name
  api_id      = aws_apigatewayv2_api.microcms.id
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.apigw_logs.arn
    format = jsonencode({
      "requestId" : "$context.requestId",
      "ip" : "$context.identity.sourceIp",
      "requestTime" : "$context.requestTime",
      "httpMethod" : "$context.httpMethod",
      "routeKey" : "$context.routeKey",
      "status" : "$context.status",
      "protocol" : "$context.protocol",
      "responseLength" : "$context.responseLength"
    })
  }

  tags = {
    Name = local.api_stage_name
  }
}