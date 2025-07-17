/**
* Certificate for the jwt-issuer
*
* This module creates a certificate for the jwt-issuer
*
* The certificate is used to secure the jwt-issuer API Gateway and Cloudfront distribution
*
*/

resource "aws_acm_certificate" "cert" {
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  tags                      = var.tags
  validation_method         = "DNS"
}

resource "aws_route53_record" "cert_validation" {
  depends_on = [aws_acm_certificate.cert]
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.zone_id
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
  timeouts {
    create = "15m"
  }
}
