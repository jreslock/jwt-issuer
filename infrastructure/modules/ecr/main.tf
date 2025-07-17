/**
    * ECR
*
* This module creates an ECR repository for the jwt-issuer
* The repository is used to store the Docker image for the Lambda function
*/

resource "aws_ecr_repository" "repository" {
  name = var.name
}
