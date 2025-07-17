terraform {
  backend "s3" {}
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=6.2.0"
    }
    external = {
      source  = "hashicorp/external"
      version = ">=2.3.1"
    }
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = ">=2.1.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">=4.1.0"
    }
  }
}
