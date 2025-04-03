locals {
  og_image_policy = "${local.og_project_name}-policy"
  og_image_role   = "${local.og_project_name}-role"
  blog_policy     = "${local.blog_project_name}-policy"
  blog_role       = "${local.blog_project_name}-role"
}

#-----------------------------------------
# AssumeRole
#-----------------------------------------
data "aws_iam_policy_document" "codebuild_assumerole" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

#-----------------------------------------
# IAM Policy(Open Graph)
#-----------------------------------------
data "aws_iam_policy_document" "og_image" {
  statement {
    sid    = "AllowCloudWatchLogsAccess"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      aws_cloudwatch_log_group.og_project_logs.arn,
      "${aws_cloudwatch_log_group.og_project_logs.arn}:*"
    ]
  }
  statement {
    sid    = "AllowS3BucketAccess"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation"
    ]
    resources = [
      aws_s3_bucket.og.arn,
      "${aws_s3_bucket.og.arn}/*"
    ]
  }
  statement {
    sid    = "AllowSSMParameterAccess"
    effect = "Allow"
    actions = [
      "ssm:GetParameters"
    ]
    resources = [
      "arn:aws:ssm:ap-northeast-1:${local.account_id}:parameter/CodeBuild/*"
    ]
  }
}

resource "aws_iam_policy" "og_image" {
  name   = local.og_image_policy
  policy = data.aws_iam_policy_document.og_image.json

  tags = {
    Name = local.og_image_policy
  }
}

#-----------------------------------------
# IAM Role(Open Graph)
#-----------------------------------------
resource "aws_iam_role" "og_image" {
  name               = local.og_image_role
  assume_role_policy = data.aws_iam_policy_document.codebuild_assumerole.json

  tags = {
    Name = local.og_image_role
  }
}

resource "aws_iam_role_policy_attachment" "og_image" {
  role       = aws_iam_role.og_image.name
  policy_arn = aws_iam_policy.og_image.arn
}

resource "aws_iam_role_policy_attachment" "og_s3_policy" {
  role       = aws_iam_role.og_image.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "og_ssm_policy" {
  role       = aws_iam_role.og_image.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "og_kms_policy" {
  role       = aws_iam_role.og_image.name
  policy_arn = "arn:aws:iam::aws:policy/AWSKeyManagementServicePowerUser"
}

resource "aws_iam_role_policy_attachment" "og_cf_policy" {
  role       = aws_iam_role.og_image.name
  policy_arn = "arn:aws:iam::aws:policy/CloudFrontFullAccess"
}

#-----------------------------------------
# IAM Policy(Blog)
#-----------------------------------------
data "aws_iam_policy_document" "blog" {
  statement {
    sid    = "AllowCloudWatchLogsAccess"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      aws_cloudwatch_log_group.blog_project_logs.arn,
      "${aws_cloudwatch_log_group.blog_project_logs.arn}:*"
    ]
  }
  statement {
    sid    = "AllowS3BucketAccess"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation"
    ]
    resources = [
      aws_s3_bucket.app.arn,
      "${aws_s3_bucket.app.arn}/*"
    ]
  }
  statement {
    sid    = "AllowSSMParameterAccess"
    effect = "Allow"
    actions = [
      "ssm:GetParameters"
    ]
    resources = [
      "arn:aws:ssm:ap-northeast-1:${local.account_id}:parameter/CodeBuild/*"
    ]
  }
}

resource "aws_iam_policy" "blog" {
  name   = local.blog_policy
  policy = data.aws_iam_policy_document.blog.json

  tags = {
    Name = local.blog_policy
  }
}

#-----------------------------------------
# IAM Role(Blog)
#-----------------------------------------
resource "aws_iam_role" "blog" {
  name               = local.blog_role
  assume_role_policy = data.aws_iam_policy_document.codebuild_assumerole.json

  tags = {
    Name = local.blog_role
  }
}

resource "aws_iam_role_policy_attachment" "blog" {
  role       = aws_iam_role.blog.name
  policy_arn = aws_iam_policy.blog.arn
}

resource "aws_iam_role_policy_attachment" "blog_s3_policy" {
  role       = aws_iam_role.blog.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "blog_ssm_policy" {
  role       = aws_iam_role.blog.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "blog_kms_policy" {
  role       = aws_iam_role.blog.name
  policy_arn = "arn:aws:iam::aws:policy/AWSKeyManagementServicePowerUser"
}

resource "aws_iam_role_policy_attachment" "blog_cf_policy" {
  role       = aws_iam_role.blog.name
  policy_arn = "arn:aws:iam::aws:policy/CloudFrontFullAccess"
}
