locals {
  cf_log_source      = "${local.name_prefix}-cf-log-src"
  cf_log_destination = "${local.name_prefix}-cf-log-dest"
  cf_log_delivery    = "${local.name_prefix}-cf-log-delivery"
}

#-----------------------------------------
# CloudWatch Logs Delivery
#-----------------------------------------
resource "aws_cloudwatch_log_delivery_source" "cf_log" {
  provider = aws.virginia

  name         = local.cf_log_source
  log_type     = "ACCESS_LOGS"
  resource_arn = aws_cloudfront_distribution.blog.arn

  tags = {
    Name = local.cf_log_source
  }
}

resource "aws_cloudwatch_log_delivery_destination" "s3" {
  provider = aws.virginia

  name          = local.cf_log_destination
  output_format = "w3c"

  delivery_destination_configuration {
    destination_resource_arn = aws_s3_bucket.cf_log.arn
  }

  tags = {
    Name = local.cf_log_destination
  }
}

resource "aws_cloudwatch_log_delivery" "cf_log_delivery" {
  provider = aws.virginia

  delivery_source_name     = aws_cloudwatch_log_delivery_source.cf_log.name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.s3.arn

  s3_delivery_configuration {
    suffix_path                 = "/{yyyy}/{MM}/{dd}/"
    enable_hive_compatible_path = false
  }

  tags = {
    Name = local.cf_log_delivery
  }
}