output "snowflake_oauth_integration_id" {
  description = "The ID of the Snowflake OAuth integration"
  value       = snowflake_external_oauth_integration.snowflake_oauth.id
}
