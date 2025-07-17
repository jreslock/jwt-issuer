/**
* API Gateway for the token vendor service
*
* This module creates an API Gateway for the token vendor service
* and configures it to use the token vendor lambda function.
*
* The API Gateway is configured to use IAM authentication.
*
*/

resource "aws_api_gateway_rest_api" "api" {
  name        = var.name
  description = "API Gateway for /token endpoint"
}

resource "aws_api_gateway_resource" "token" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "token"
}

resource "aws_api_gateway_method" "token_post" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.token.id
  http_method   = "POST"
  authorization = "AWS_IAM"
}

resource "aws_api_gateway_integration" "issuer_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.token.id
  http_method             = aws_api_gateway_method.token_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.issuer_lambda_invoke_arn
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on  = [aws_api_gateway_integration.issuer_lambda]
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_stage" "v1" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "v1"
}

data "aws_iam_policy_document" "api_gateway_policy" {
  statement {
    actions   = ["apigateway:Invoke"]
    effect    = "Allow"
    resources = [aws_api_gateway_rest_api.api.execution_arn]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = [var.organization_id]
    }
  }
}

resource "aws_api_gateway_rest_api_policy" "api_gateway_policy" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  policy      = data.aws_iam_policy_document.api_gateway_policy.json
}

resource "aws_api_gateway_domain_name" "domain_name" {
  certificate_arn = var.certificate_arn
  domain_name     = var.domain_name
}

resource "aws_api_gateway_base_path_mapping" "base_path_mapping" {
  api_id      = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_stage.v1.stage_name
  domain_name = aws_api_gateway_domain_name.domain_name.domain_name
}

resource "aws_route53_record" "custom_domain" {
  name    = var.name
  type    = "A"
  zone_id = var.tld_zone_id

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.domain_name.cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.domain_name.cloudfront_zone_id
  }
}

data "aws_wafv2_web_acl" "default_regional_waf_acl" {
  name  = "default-regional"
  scope = "REGIONAL"
}

resource "aws_wafv2_web_acl_association" "api_gateway_waf_acl_association" {
  resource_arn = aws_api_gateway_stage.v1.arn
  web_acl_arn  = var.web_acl_arn
}

resource "aws_api_gateway_resource" "jwks" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = ".well-known"
}

resource "aws_api_gateway_resource" "jwks_json" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.jwks.id
  path_part   = "jwks.json"
}

resource "aws_api_gateway_method" "jwks_get" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.jwks_json.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "jwks_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.jwks_json.id
  http_method             = aws_api_gateway_method.jwks_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.jwks_lambda_invoke_arn
}
