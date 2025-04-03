resource "aws_acm_certificate" "cf_cert" {
  provider = aws.virginia

  domain_name       = local.fqdn
  validation_method = "DNS"
}

resource "aws_acm_certificate_validation" "cf_cert" {
  provider = aws.virginia

  certificate_arn = aws_acm_certificate.cf_cert.arn
  validation_record_fqdns = [
    for record in aws_route53_record.acm_dns_resolve : record.fqdn
  ]
}