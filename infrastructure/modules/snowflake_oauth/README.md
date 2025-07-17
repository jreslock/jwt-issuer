Snowflake OAuth integration

This module creates a Snowflake OAuth integration

The Snowflake OAuth integration is configured to use the provided
well-known location to retrieve the public key to verify tokens.

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
| <a name="provider_snowflake"></a> [snowflake](#provider\_snowflake) | n/a |



## Resources

| Name | Type |
|------|------|
| [snowflake_external_oauth_integration.snowflake_oauth](https://registry.terraform.io/providers/snowflakedb/snowflake/latest/docs/resources/external_oauth_integration) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_audience_list"></a> [audience\_list](#input\_audience\_list) | The audience list for the Snowflake OAuth integration | `list(string)` | n/a | yes |
| <a name="input_comment"></a> [comment](#input\_comment) | The comment for the Snowflake OAuth integration | `string` | n/a | yes |
| <a name="input_issuer_url"></a> [issuer\_url](#input\_issuer\_url) | The issuer URL for the Snowflake OAuth integration | `string` | n/a | yes |
| <a name="input_jws_keys_url"></a> [jws\_keys\_url](#input\_jws\_keys\_url) | The JWS keys URL for the Snowflake OAuth integration | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the Snowflake OAuth integration | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_snowflake_oauth_integration_id"></a> [snowflake\_oauth\_integration\_id](#output\_snowflake\_oauth\_integration\_id) | The ID of the Snowflake OAuth integration |
