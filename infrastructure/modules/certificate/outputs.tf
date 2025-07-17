output "certificate_arn" {
  description = "The ARN of the certificate"
  value       = aws_acm_certificate.jwt_issuer_certificate.arn
}

output "certificate_domain_name" {
  description = "The domain name of the certificate"
  value       = aws_acm_certificate.jwt_issuer_certificate.domain_name
}

output "certificate_subject_alternative_names" {
  description = "The subject alternative names of the certificate"
  value       = aws_acm_certificate.jwt_issuer_certificate.subject_alternative_names
}
