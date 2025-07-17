/**
* Snowflake OAuth integration
*
* This module creates a Snowflake OAuth integration
*
* The Snowflake OAuth integration is configured to use the provided
* well-known location to retrieve the public key to verify tokens.
*
*/

resource "snowflake_external_oauth_integration" "snowflake_oauth" {
  name    = var.name
  comment = var.comment

  enabled = true

  external_oauth_type                             = "CUSTOM"
  external_oauth_issuer                           = var.issuer_url
  external_oauth_jws_keys_url                     = var.jws_keys_url
  external_oauth_audience_list                    = var.audience_list
  external_oauth_token_user_mapping_claim         = ["sub"]      # Typically IAM role or user
  external_oauth_snowflake_user_mapping_attribute = "LOGIN_NAME" # Maps "sub" → Snowflake user
  external_oauth_any_role_mode                    = "ENABLE"
}
