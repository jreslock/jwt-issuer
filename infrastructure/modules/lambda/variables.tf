variable "api_gateway_execution_arn" {
  type        = string
  description = "Execution ARN of the API Gateway to allow invoke on the Lambda function"
}

variable "name" {
  type        = string
  description = "Name of the Lambda function"
}

variable "image_uri" {
  type        = string
  description = "URI of the Lambda function image"
}

variable "lambda_environment_variables" {
  type        = map(string)
  description = "Environment variables for the Lambda function"
  default     = {}
}
