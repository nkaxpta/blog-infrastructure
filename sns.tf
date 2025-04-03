locals {
  acm_topic_name       = "${local.name_prefix}-acm-expiration-topic"
  codebuild_topic_name = "${local.name_prefix}-start-codebuild-topic"
}

#-----------------------------------------
# SNS Topic(ACM)
#-----------------------------------------
resource "aws_sns_topic" "acm_expiration" {
  name         = local.acm_topic_name
  display_name = local.acm_topic_name

  tags = {
    Name = local.acm_topic_name
  }
}

#-----------------------------------------
# SNS Subscription(ACM)
#-----------------------------------------
resource "aws_sns_topic_subscription" "acm_to_sns" {
  topic_arn = aws_sns_topic.acm_expiration.arn
  protocol  = "email"
  endpoint  = var.email
}

#-----------------------------------------
# SNS Topic(CodeBuild)
#-----------------------------------------
resource "aws_sns_topic" "start_codebulid" {
  name         = local.codebuild_topic_name
  display_name = local.codebuild_topic_name

  tags = {
    Name = local.codebuild_topic_name
  }
}

#-----------------------------------------
# SNS Subscription(CodeBuild)
#-----------------------------------------
resource "aws_sns_topic_subscription" "codebuild_to_sns" {
  topic_arn = aws_sns_topic.start_codebulid.arn
  protocol  = "email"
  endpoint  = var.email
}
