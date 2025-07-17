resource "aws_lambda_function" "lambda_function" {
  function_name = var.name
  image_uri     = var.image_uri
  role          = aws_iam_role.lambda_role.arn
  package_type  = "Image"
  architectures = ["x86_64"]
  timeout       = 300
  memory_size   = 256
  publish       = true
  environment {
    variables = {
      for k, v in var.lambda_environment_variables : k => v
    }
  }
}

resource "aws_lambda_alias" "lambda_alias" {
  name             = var.name
  function_name    = aws_lambda_function.lambda_function.function_name
  function_version = aws_lambda_function.lambda_function.version
  # Create the alias but don't update it when the version changes
  # We will manage updating the alias via a separeate deployment
  # pipeline
  lifecycle {
    ignore_changes = [
      function_version
    ]
  }
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.name}"
  retention_in_days = 7
}

resource "aws_iam_role" "lambda_role" {
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_role_policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    effect = "Allow"
    resources = [
      "arn:aws:logs:${module.aws_context.region}:${module.aws_context.account_id}:log-group:/aws/lambda/${var.name}:*"
    ]
  }
}

resource "aws_iam_role_policy" "lambda_role_policy" {
  name   = var.name
  role   = aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.lambda_role_policy.json
}

resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_gateway_execution_arn}/*"
}
