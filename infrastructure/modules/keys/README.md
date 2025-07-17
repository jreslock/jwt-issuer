Keys

This module creates a key pair for the jwt-issuer
The key pair is stored in Secrets Manager
The public key is used to create the jwks.json file
and served via the .well-known endpoint from S3/Cloudfront
Increment the input variable to rotate the key pair

## Changelog

### 0.0.1
- Initial

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.10.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_external"></a> [external](#provider\_external) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |



## Resources

| Name | Type |
|------|------|
| [aws_secretsmanager_secret.keys](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.keys](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_ssm_parameter.jwks_json](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [random_id.secret_key](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [tls_private_key.key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [external_external.jwks](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_increment_to_rotate"></a> [increment\_to\_rotate](#input\_increment\_to\_rotate) | The increment to rotate the key pair | `number` | `1` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the infrastructure | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_jwks_ssm_param_name"></a> [jwks\_ssm\_param\_name](#output\_jwks\_ssm\_param\_name) | The name of the SSM parameter for the JWKS JSON |
| <a name="output_public_key"></a> [public\_key](#output\_public\_key) | The public key for the jwt-issuer |
| <a name="output_secret_id"></a> [secret\_id](#output\_secret\_id) | The secret ID for the jwt-issuer |
