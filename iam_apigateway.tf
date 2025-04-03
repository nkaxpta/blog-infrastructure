locals {
  apigw_policy_name = "${local.name_prefix}-apigw-putevent-policy"
  apigw_role_name   = "${local.name_prefix}-apigw-role"
}

#-----------------------------------------
# Assume Role
#-----------------------------------------
data "aws_iam_policy_document" "apigw_assumerole" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

#-----------------------------------------
# IAM Policy
#-----------------------------------------
data "aws_iam_policy_document" "apigw_launch_eventbridge" {
  statement {
    sid       = "AllowEventBridgePutEvents"
    effect    = "Allow"
    actions   = ["events:PutEvents"]
    resources = ["arn:aws:events:*:${local.account_id}:event-bus/*"]
  }
}

resource "aws_iam_policy" "apigw_launch_eventbridge" {
  name   = local.apigw_policy_name
  policy = data.aws_iam_policy_document.apigw_launch_eventbridge.json

  tags = {
    Name = local.apigw_policy_name
  }
}

#-----------------------------------------
# IAM Role
#-----------------------------------------
resource "aws_iam_role" "apigw_role" {
  name               = local.apigw_role_name
  assume_role_policy = data.aws_iam_policy_document.apigw_assumerole.json

  tags = {
    Name = local.apigw_role_name
  }
}

resource "aws_iam_role_policy_attachment" "apigw_launch_eventbridge" {
  role       = aws_iam_role.apigw_role.name
  policy_arn = aws_iam_policy.apigw_launch_eventbridge.arn
}

resource "aws_iam_role_policy_attachment" "apigw_push_cwlogs" {
  role       = aws_iam_role.apigw_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}