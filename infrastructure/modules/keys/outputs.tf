output "jwks_ssm_param_name" {
  description = "The name of the SSM parameter for the JWKS JSON"
  value       = aws_ssm_parameter.jwks_json.name
}

output "public_key" {
  description = "The public key for the jwt-issuer"
  value       = local.public_key_pem_trimmed
}

output "secret_id" {
  description = "The secret ID for the jwt-issuer"
  value       = aws_secretsmanager_secret.keys.id
}
