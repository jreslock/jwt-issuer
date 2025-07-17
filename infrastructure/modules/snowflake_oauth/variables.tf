variable "audience_list" {
  description = "The audience list for the Snowflake OAuth integration"
  type        = list(string)
}

variable "comment" {
  description = "The comment for the Snowflake OAuth integration"
  type        = string
}

variable "issuer_url" {
  description = "The issuer URL for the Snowflake OAuth integration"
  type        = string
}

variable "jws_keys_url" {
  description = "The JWS keys URL for the Snowflake OAuth integration"
  type        = string
}

variable "name" {
  description = "The name of the Snowflake OAuth integration"
  type        = string
}
