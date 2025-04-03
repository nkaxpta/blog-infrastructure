locals {
  cloudfront_name  = "${local.name_prefix}-app-cf"
  cf_function_name = "${local.name_prefix}-suffix-index"
}

#-----------------------------------------
# CloudFront
#-----------------------------------------
# デフォルトのキャッシュ動作
data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

resource "aws_cloudfront_distribution" "blog" {
  aliases = [local.fqdn]

  origin {
    domain_name         = aws_s3_bucket.app.bucket_regional_domain_name
    connection_attempts = 3
    connection_timeout  = 10
    origin_id           = aws_s3_bucket.app.bucket_regional_domain_name
  }

  enabled             = true
  is_ipv6_enabled     = true
  http_version        = "http2and3"
  wait_for_deployment = true
  price_class         = "PriceClass_All"

  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 403
    response_code         = 403
    response_page_path    = "/404.html"
  }
  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 404
    response_code         = 404
    response_page_path    = "/404/index.html"
  }

  default_cache_behavior {
    target_origin_id = aws_s3_bucket.app.bucket_regional_domain_name
    cache_policy_id  = data.aws_cloudfront_cache_policy.caching_optimized.id
    allowed_methods = [
      "GET",
      "HEAD"
    ]
    cached_methods = [
      "GET",
      "HEAD"
    ]
    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.suffix_function.arn
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cf_cert.arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = local.cloudfront_name
  }
}

#-----------------------------------------
# CloudFront functions
#-----------------------------------------
resource "aws_cloudfront_function" "suffix_function" {
  name    = local.cf_function_name
  runtime = "cloudfront-js-2.0"
  comment = "CloudFront Function for Request URI Handling and Domain Validation"
  publish = true
  code    = file("src/suffix_index.js")
}
