/**
* Root module for jwt-issuer
*
* This module creates an API Gateway, Cloudfront, S3 bucket, Certificate
* lambda function, keys in secrets manager, dummy snowflake oauth integration
* The API is protected by requiring AWS_IAM authentication and that the
* principal executing the API is a member of the current session's AWS Organization
*
* To use this module you must deploy the ECR repositories first
* Once the ECRs exist you can push images to them
* Once there are images, the remaining infrastructure can be deployed
*/

locals {
  issuer_ecr_url = var.create_ecr ? module.issuer_ecr[0].repository_url : data.aws_ecr_repository.issuer_ecr[0].repository_url
  jwks_ecr_url   = var.create_ecr ? module.jwks_ecr[0].repository_url : data.aws_ecr_repository.jwks_ecr[0].repository_url
}

# Create the ECR repository (dev)
module "issuer_ecr" {
  count  = var.create_ecr ? 1 : 0
  source = "./modules/ecr"
  name   = var.issuer_ecr_name
}

# Get the ECR repository if we aren't creating it (prod)
data "aws_ecr_repository" "issuer_ecr" {
  count = var.create_ecr ? 0 : 1
  name  = var.issuer_ecr_name
}

module "jwks_ecr" {
  count  = var.create_ecr ? 1 : 0
  source = "./modules/ecr"
  name   = var.jwks_ecr_name
}

data "aws_ecr_repository" "jwks_ecr" {
  count = var.create_ecr ? 0 : 1
  name  = var.jwks_ecr_name
}

# # Get the organization ID for the current AWS Organization
# data "aws_organizations_organization" "organization" {}

# # Create the API Gateway
# module "apigw" {
#   source = "./modules/api"

#   certificate_arn          = module.certificate.certificate_arn
#   domain_name              = module.certificate.domain_name
#   issuer_lambda_invoke_arn = module.lambda.lambda_function_invoke_arn
#   jwks_lambda_invoke_arn   = module.lambda_jwks.lambda_function_invoke_arn
#   name                     = var.name
#   organization_id          = data.aws_organizations_organization.organization.id
#   tld_zone_id              = data.aws_route53_zone.tld_zone.zone_id
#   web_acl_arn              = module.waf.web_acl_default_regional_arn
# }

# # Get the Route 53 zone ID for the top-level domain
# # This is used to create the certificate for the jwt-issuer
# data "aws_route53_zone" "tld_zone" {
#   name         = var.domain
#   private_zone = false
# }

# # Create the certificate
# module "certificate" {
#   source                    = "./modules/certificate"
#   domain_name               = "${var.name}.${var.domain}"
#   subject_alternative_names = []
#   zone_id                   = data.aws_route53_zone.tld_zone.zone_id
#   tags = {
#     Name = "${var.name}-certificate"
#   }
# }

# # Create the keys
# module "keys" {
#   source = "./modules/keys"
#   name   = var.name
# }

# # Create the lambda function
# module "issuer_lambda" {
#   source                    = "./modules/lambda"
#   name                      = var.name
#   image_uri                 = "${local.issuer_ecr_url}:${var.issuer_image_tag}"
#   api_gateway_execution_arn = module.apigw.api_gateway_execution_arn
#   lambda_environment_variables = {
#     AUDIENCE               = "https://mysnowflakeaccount.snowflakecomputing.com"
#     JWT_ISSUER_URL         = "https://${module.certificate.domain_name}"
#     JWT_ISSUER_JWKS_URL    = "https://${module.certificate.domain_name}/.well-known/jwks.json"
#     SIGNING_KEY_SECRET_ARN = module.keys.secret_id
#   }
# }

# # Create the JWKS lambda function
# module "jwks_lambda" {
#   source                    = "./modules/lambda"
#   name                      = "${var.name}-jwks"
#   image_uri                 = "${local.jwks_ecr_url}:${var.jwks_image_tag}"
#   api_gateway_execution_arn = module.apigw.api_gateway_execution_arn
#   lambda_environment_variables = {
#     JWKS_SSM_PARAM = module.keys.jwks_ssm_param_name
#   }
# }

# # Create the WAF rules and web ACLs
# module "waf" {
#   source = "./modules/waf"
#   name   = var.name
# }

# When using a custom oauth integration, uncomment the following lines as well as the provider block in providers.tf
# Create the snowflake oauth integration
# module "snowflake_oauth" {
#     source = "./modules/snowflake_oauth"
#
#     name          = "snowflake_oauth"
#     comment       = "Snowflake OAuth integration for the jwt-issuer"
#     issuer_url    = "https://${module.certificate.domain_name}"
#     jws_keys_url  = "https://${module.certificate.domain_name}/.well-known/jwks.json"
#     audience_list = ["https://youraccountidentifier.snowflakecomputing.com"]
# }
