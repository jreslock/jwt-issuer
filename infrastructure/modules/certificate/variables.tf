variable "domain_name" {
  description = "The domain name for the certificate"
  type        = string
}

variable "subject_alternative_names" {
  description = "The subject alternative names for the certificate"
  type        = list(string)
}

variable "tags" {
  description = "The tags for the certificate"
  type        = map(string)
}

variable "zone_id" {
  description = "The Route 53 zone ID for the certificate"
  type        = string
}
