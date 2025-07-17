variable "create_ecr" {
  description = "Whether to create the ECR repository. Only need one to be true"
  type        = bool
  default     = false
}

variable "domain" {
  description = "The domain name to use for lookup of the Route 53 zone ID. You must own this domain"
  type        = string
}

variable "issuer_ecr_name" {
  description = "The name of the issuer Lambda ECR repository"
  type        = string
}

variable "jwks_ecr_name" {
  description = "The name of the JWKS Lambda ECR repository"
  type        = string
}

variable "issuer_image_tag" {
  description = "The tag of the image to use for the issuer Lambda function"
  type        = string
}

variable "jwks_image_tag" {
  description = "The tag of the image to use for the JWKS Lambda function"
  type        = string
}

variable "name" {
  description = "The name of the infrastructure"
  type        = string
}

variable "region" {
  description = "The region to deploy the infrastructure to"
  type        = string
}

variable "role_arn" {
  description = "The ARN of the role to assume"
  type        = string
}
