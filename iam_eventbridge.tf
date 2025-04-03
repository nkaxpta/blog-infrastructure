locals {
  eventbridge_blog_policy_name = "${local.name_prefix}-eventbridge-codebulid-blog-policy"
  eventbridge_blog_role_name   = "${local.name_prefix}-eventbridge-codebulid-blog-role"
  eventbridge_og_policy_name   = "${local.name_prefix}-eventbridge-codebulid-og-policy"
  eventbridge_og_role_name     = "${local.name_prefix}-eventbridge-codebulid-og-role"
}

#-----------------------------------------
# Assume Role
#-----------------------------------------
data "aws_iam_policy_document" "eventbridge_assumerole" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

#-----------------------------------------
# IAM Policy(Blog)
#-----------------------------------------
data "aws_iam_policy_document" "codebulid_blog" {
  statement {
    sid       = "AllowCodeBuildProjectStart"
    effect    = "Allow"
    actions   = ["codebuild:StartBuild"]
    resources = [aws_codebuild_project.blog_create.arn]
  }
}

resource "aws_iam_policy" "codebulid_blog" {
  name   = local.eventbridge_blog_policy_name
  policy = data.aws_iam_policy_document.codebulid_blog.json

  tags = {
    Name = local.eventbridge_blog_policy_name
  }
}

#-----------------------------------------
# IAM Role(Blog)
#-----------------------------------------
resource "aws_iam_role" "codebulid_blog" {
  name               = local.eventbridge_blog_role_name
  assume_role_policy = data.aws_iam_policy_document.eventbridge_assumerole.json

  tags = {
    Name = local.eventbridge_blog_role_name
  }
}

resource "aws_iam_role_policy_attachment" "codebulid_blog" {
  role       = aws_iam_role.codebulid_blog.name
  policy_arn = aws_iam_policy.codebulid_blog.arn
}

#-----------------------------------------
# IAM Policy(Open Graph)
#-----------------------------------------
data "aws_iam_policy_document" "codebulid_og" {
  statement {
    sid       = "AllowCodeBuildProjectStart"
    effect    = "Allow"
    actions   = ["codebuild:StartBuild"]
    resources = [aws_codebuild_project.og_image_create.arn]
  }
}

resource "aws_iam_policy" "codebulid_og" {
  name   = local.eventbridge_og_policy_name
  policy = data.aws_iam_policy_document.codebulid_og.json

  tags = {
    Name = local.eventbridge_og_policy_name
  }
}

#-----------------------------------------
# IAM Role(Open Graph)
#-----------------------------------------
resource "aws_iam_role" "codebulid_og" {
  name               = local.eventbridge_og_role_name
  assume_role_policy = data.aws_iam_policy_document.eventbridge_assumerole.json

  tags = {
    Name = local.eventbridge_og_role_name
  }
}

resource "aws_iam_role_policy_attachment" "codebulid_og" {
  role       = aws_iam_role.codebulid_og.name
  policy_arn = aws_iam_policy.codebulid_og.arn
}
