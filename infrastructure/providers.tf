provider "aws" {
  region = var.region
  assume_role {
    role_arn = var.role_arn
  }
}

# Snowflake provider
# https://registry.terraform.io/providers/snowflakedb/snowflake/latest/docs
# To create a Snowflake custom_oauth_integration, uncomment the following lines:
# and also uncomment the "snowflake" module call in main.tf
#
# This requires a snowflake account with a user that can use the ACCOUNTADMIN role
# and a private key for the user stored in SSM Parameter Store
# provider "snowflake" {
#   account       = var.snowflake_account
#   authenticator = "SNOWFLAKE_JWT"
#   private_key   = data.aws_ssm_parameter.snowflake_private_key.value
#   username      = var.snowflake_username
#   role          = "ACCOUNTADMIN"
#   warehouse     = "ACME"

#   preview_features_enabled = [
#     "snowflake_file_format_resource",
#     "snowflake_function_javascript_resource",
#     "snowflake_network_policy_attachment_resource",
#     "snowflake_procedure_javascript_resource",
#     "snowflake_procedure_sql_resource",
#     "snowflake_procedures_datasource",
#     "snowflake_api_integration_resource",
#     "snowflake_storage_integration_resource",
#     "snowflake_stage_resource"
#   ]
# }

# data "aws_ssm_parameter" "snowflake_private_key" {
#   name = var.private_key_ssm_path
#   with_decryption = true
# }
