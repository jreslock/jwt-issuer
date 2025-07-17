variable "certificate_arn" {
  description = "The ARN of the ACM certificate to use for the API's custom domain"
  type        = string
}

variable "domain_name" {
  description = "The custom domain name for the API (e.g., api.example.com)"
  type        = string
}

variable "issuer_lambda_invoke_arn" {
  description = "Invoke ARN for the Issuer Lambda function"
  type        = string
}

variable "jwks_lambda_invoke_arn" {
  description = "Invoke ARN for the JWKS Lambda function"
  type        = string
}

variable "name" {
  description = "The name to assign to the API Gateway and related resources"
  type        = string
}

variable "organization_id" {
  description = "The AWS Organization ID for resource scoping and tagging"
  type        = string
}

variable "tld_zone_id" {
  description = "The Route53 Hosted Zone ID for the top-level domain"
  type        = string
}

variable "web_acl_arn" {
  description = "The ARN of the AWS WAF Web ACL to associate with the API Gateway"
  type        = string
}
