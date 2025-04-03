#-----------------------------------------
# Route53 Zone
#-----------------------------------------
data "aws_route53_zone" "domain" {
  name = local.domain
}

#-----------------------------------------
# Record
#-----------------------------------------
resource "aws_route53_record" "cloudfront_a_record" {
  zone_id = data.aws_route53_zone.domain.id
  name    = local.fqdn
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.blog.domain_name
    zone_id                = aws_cloudfront_distribution.blog.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "acm_dns_resolve" {
  for_each = {
    for dvo in aws_acm_certificate.cf_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  allow_overwrite = true
  zone_id         = data.aws_route53_zone.domain.id
  name            = each.value.name
  type            = each.value.type
  ttl             = 600
  records         = [each.value.record]
}
