terraform {
  required_version = ">=1.10.1"
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    external = {
      source = "hashicorp/external"
    }
    tls = {
      source = "hashicorp/tls"
    }
  }
}
