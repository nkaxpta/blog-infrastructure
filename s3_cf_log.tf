locals {
  cf_log_bucket_name = "${local.name_prefix}-cf-logs-bucket"
}

#-----------------------------------------
# S3 Bucket(CloudFront Log)
#-----------------------------------------
resource "aws_s3_bucket" "cf_log" {
  bucket        = local.cf_log_bucket_name
  force_destroy = true

  tags = {
    Name = local.cf_log_bucket_name
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "cf_log_lifecycle" {
  bucket = aws_s3_bucket.cf_log.id

  rule {
    id     = "cloudfront_log_expiration_rule"
    status = "Enabled"

    filter {
      prefix = "${local.cf_logs_prefix}/"
    }
    expiration {
      days = 180
    }
  }
}

#-----------------------------------------
# S3 Bucket Policy
#-----------------------------------------
# CloudFrontのログ書き込み権限を追加
data "aws_iam_policy_document" "allow_cf_log_policy" {
  statement {
    sid    = "AllowLogDelivery"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.cf_log.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.account_id]
    }
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:logs:us-east-1:${local.account_id}:delivery-source:*"]
    }
  }
}

resource "aws_s3_bucket_policy" "cf_log" {
  bucket = aws_s3_bucket.cf_log.id
  policy = data.aws_iam_policy_document.allow_cf_log_policy.json
}
