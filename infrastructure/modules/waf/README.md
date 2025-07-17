WAF

This module creates a WAF for the jwt-issuer
The WAF is used to protect the jwt-issuer from attacks
The WAF is configured to allow traffic from the jwt-issuer
The WAF is configured to block traffic from the jwt-issuer

## Changelog

### 0.0.1
- Initial



## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |



## Resources

| Name | Type |
|------|------|
| [aws_wafv2_web_acl.regional_default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_waf_managed_common_rule_set_version"></a> [aws\_waf\_managed\_common\_rule\_set\_version](#input\_aws\_waf\_managed\_common\_rule\_set\_version) | The version of the AWS WAF managed rule group to use | `string` | `"1.15"` | no |
| <a name="input_aws_waf_managed_known_bad_inputs_rule_set_version"></a> [aws\_waf\_managed\_known\_bad\_inputs\_rule\_set\_version](#input\_aws\_waf\_managed\_known\_bad\_inputs\_rule\_set\_version) | The version of the AWS WAF managed rule group to use | `string` | `"1.22"` | no |
| <a name="input_cloudwatch_logging_enabled"></a> [cloudwatch\_logging\_enabled](#input\_cloudwatch\_logging\_enabled) | Whether to enable logging for the WAF | `bool` | `false` | no |
| <a name="input_cloudwatch_metrics_enabled"></a> [cloudwatch\_metrics\_enabled](#input\_cloudwatch\_metrics\_enabled) | Whether to enable CloudWatch metrics for the WAF | `bool` | `false` | no |
| <a name="input_cloudwatch_retention_days"></a> [cloudwatch\_retention\_days](#input\_cloudwatch\_retention\_days) | The number of days to retain CloudWatch logs | `number` | `7` | no |
| <a name="input_default_action"></a> [default\_action](#input\_default\_action) | The default action to take for the WAF | `string` | `"allow"` | no |
| <a name="input_name"></a> [name](#input\_name) | The name to use for resources created by this module | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_web_acl_default_regional_arn"></a> [web\_acl\_default\_regional\_arn](#output\_web\_acl\_default\_regional\_arn) | The ARN of the regional web ACL allowing all traffic which uses the AWS Managed Common Rule Set |
