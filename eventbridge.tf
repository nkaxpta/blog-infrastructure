locals {
  acm_expiration_rule_name  = "${local.name_prefix}-acm-expiration-rule"
  start_codebuild_rule_name = "${local.name_prefix}-start-codebuild-rule"
  build_to_build_rule_name  = "${local.name_prefix}-build-to-build-rule"
  build_to_lambda_rule_name = "${local.name_prefix}-build-to-lambda-rule"
}

#-----------------------------------------
# EventBridge(ACM expiration)
#-----------------------------------------
resource "aws_cloudwatch_event_rule" "acm_expiration" {
  name = local.acm_expiration_rule_name
  event_pattern = jsonencode(
    {
      "source" : ["aws.acm"],
      "detail-type" : ["ACM Certificate Approaching Expiration"]
    }
  )

  tags = {
    Name = local.acm_expiration_rule_name
  }
}

resource "aws_cloudwatch_event_target" "acm_expiration_sns" {
  rule = aws_cloudwatch_event_rule.acm_expiration.name
  arn  = aws_sns_topic.acm_expiration.arn

  input_transformer {
    input_paths = {
      Account    = "$.account"
      CommonName = "$.detail.CommonName"
      Expiry     = "$.detail.DaysToExpiry"
      Region     = "$.region"
      Resource   = "$.resources"
      Time       = "$.time"
    }
    input_template = <<-EOT
"ACMの有効期限が迫ってきています。"

"AWS Account ID: <Account>"
"Time: <Time>"
"Region: <Region>"
"Resource: <Resource>"
"Expiry: <Expiry>"
"CommonName: <CommonName>"
EOT
  }
}

#-----------------------------------------
# EventBridge(Start CodeBuild)
#-----------------------------------------
resource "aws_cloudwatch_event_rule" "start_codebuild" {
  name = local.start_codebuild_rule_name
  event_pattern = jsonencode(
    {
      "source" : [data.aws_ssm_parameter.microcms_api_domain.value],
      "detail-type" : [var.microcms_content]
    }
  )

  tags = {
    Name = local.start_codebuild_rule_name
  }
}

resource "aws_cloudwatch_event_target" "start_codebuild_sns" {
  rule = aws_cloudwatch_event_rule.start_codebuild.name
  arn  = aws_sns_topic.start_codebulid.arn

  input_transformer {
    input_paths = {
      Account      = "$.account"
      BlogCategory = "$.detail.new.publishValue.categories"
      BlogId       = "$.detail.new.id"
      BlogTitle    = "$.detail.new.publishValue.title"
      Status       = "$.detail.new.status[0]"
      Time         = "$.time"
      Type         = "$.detail-type"
    }
    input_template = <<-EOT
"<Type>が投稿されました。"

"Time: <Time>"
"AWS Account ID: <Account>"
"Status: <Status>"
"Blog ID: <BlogId>"
"Blog Title: <BlogTitle>"
"Blog Category: <BlogCategory>"
EOT
  }
}

resource "aws_cloudwatch_event_target" "start_codebuild" {
  rule     = aws_cloudwatch_event_rule.start_codebuild.name
  arn      = aws_codebuild_project.og_image_create.arn
  role_arn = aws_iam_role.codebulid_og.arn
}

#-----------------------------------------
# EventBridge(CodeBuild to CodeBuild)
#-----------------------------------------
resource "aws_cloudwatch_event_rule" "to_codebuild" {
  name = local.build_to_build_rule_name
  event_pattern = jsonencode(
    {
      "source" : ["aws.codebuild"],
      "account" : [local.account_id],
      "detail-type" : ["CodeBuild Build Phase Change"],
      "detail" : {
        "completed-phase" : ["FINALIZING"],
        "project-name" : [local.og_project_name],
        "completed-phase-status" : ["SUCCEEDED"]
      }
    }
  )

  tags = {
    Name = local.build_to_build_rule_name
  }
}

resource "aws_cloudwatch_event_target" "to_codebuild" {
  rule     = aws_cloudwatch_event_rule.to_codebuild.name
  arn      = aws_codebuild_project.blog_create.arn
  role_arn = aws_iam_role.codebulid_blog.arn
}

#-----------------------------------------
# EventBridge(CodeBuild to Lambda)
#-----------------------------------------
resource "aws_cloudwatch_event_rule" "to_lambda" {
  name = local.build_to_lambda_rule_name
  event_pattern = jsonencode(
    {
      "source" : ["aws.codebuild"],
      "account" : [local.account_id],
      "detail-type" : ["CodeBuild Build Phase Change"],
      "detail" : {
        "completed-phase" : ["FINALIZING"],
        "project-name" : [local.blog_project_name],
        "completed-phase-status" : ["SUCCEEDED"]
      }
    }
  )

  tags = {
    Name = local.build_to_lambda_rule_name
  }
}

resource "aws_cloudwatch_event_target" "to_lambda" {
  rule = aws_cloudwatch_event_rule.to_lambda.name
  arn  = aws_lambda_function.move_s3.arn
}
