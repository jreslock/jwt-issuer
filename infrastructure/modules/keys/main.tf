/**
* Keys
*
* This module creates a key pair for the jwt-issuer
* The key pair is stored in Secrets Manager
* The public key is used to create the jwks.json file
* and served via the .well-known endpoint from S3/Cloudfront
* Increment the input variable to rotate the key pair
*/

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096

  lifecycle {
    replace_triggered_by = [
      random_id.secret_key
    ]
  }
}

resource "random_id" "secret_key" {
  keepers = {
    increment_to_rotate = var.increment_to_rotate
  }
  byte_length = 8
}

resource "aws_secretsmanager_secret" "keys" {
  name = "jwt-issuer-keys"
}

resource "aws_secretsmanager_secret_version" "keys" {
  secret_id = aws_secretsmanager_secret.keys.id
  secret_string = jsonencode({
    private_key = tls_private_key.key.private_key_p8
    public_key  = local.public_key_pem_trimmed
  })
}

locals {
  public_key_pem_trimmed = regex("^\\-+BEGIN PUBLIC KEY\\-+(.*?)\\-+END PUBLIC KEY\\-+$", replace(tls_private_key.key.public_key_pem, "\n", ""))[0]
}

data "external" "jwks" {
  program = ["${path.module}/../../scripts/pem_to_jwks.py"]
  query = {
    public_key_pem = tls_private_key.key.public_key_pem
    kid            = random_id.secret_key.hex
  }
}

resource "aws_ssm_parameter" "jwks_json" {
  name  = "/aws/${var.name}/jwks-json"
  type  = "String"
  value = data.external.jwks.result["jwks_json"]
}
