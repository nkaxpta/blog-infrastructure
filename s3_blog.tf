locals {
  app_bucket_name = "${local.name_prefix}-app-bucket"
  og_bucket_name  = "${local.name_prefix}-og-image-bucket"
}

#-----------------------------------------
# S3(Blog)
#-----------------------------------------
resource "aws_s3_bucket" "app" {
  bucket        = local.app_bucket_name
  force_destroy = true

  tags = {
    Name = local.app_bucket_name
  }
}

resource "aws_s3_bucket_website_configuration" "app" {
  bucket = aws_s3_bucket.app.id

  index_document {
    suffix = "index.html"
  }
}

#-----------------------------------------
# S3 Bucket Policy(Blog)
#-----------------------------------------
# CloudFrontからの読み取り権限を追加
data "aws_iam_policy_document" "allow_cf_policy" {
  statement {
    sid    = "AllowCloudFrontServicePrincipal"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.app.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudfront_distribution.blog.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "cf" {
  bucket = aws_s3_bucket.app.id
  policy = data.aws_iam_policy_document.allow_cf_policy.json
}

#-----------------------------------------
# S3(Open Graph)
#-----------------------------------------
resource "aws_s3_bucket" "og" {
  bucket        = local.og_bucket_name
  force_destroy = true

  tags = {
    Name = local.og_bucket_name
  }
}

# パブリックアクセスブロック設定を無効化 ※外部公開に使用するため
resource "aws_s3_bucket_public_access_block" "og" {
  bucket = aws_s3_bucket.og.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

#-----------------------------------------
# S3 Bucket Policy(Open Graph)
#-----------------------------------------
# CloudFrontからの読み取り権限を追加
data "aws_iam_policy_document" "allow_get_policy" {
  statement {
    sid    = "Allow access"
    effect = "Allow"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.og.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "any" {
  bucket = aws_s3_bucket.og.id
  policy = data.aws_iam_policy_document.allow_get_policy.json

  depends_on = [aws_s3_bucket_public_access_block.og]
}
