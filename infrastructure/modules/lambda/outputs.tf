output "lambda_alias_arn" {
  value = aws_lambda_alias.lambda_alias.arn
}

output "lambda_alias_name" {
  value = aws_lambda_alias.lambda_alias.name
}

output "lambda_function_arn" {
  value = aws_lambda_function.lambda_function.arn
}

output "lambda_function_name" {
  value = aws_lambda_function.lambda_function.function_name
}

output "lambda_function_invoke_arn" {
  value = aws_lambda_function.lambda_function.invoke_arn
}

output "lambda_function_role_arn" {
  value = aws_iam_role.lambda_role.arn
}

output "lambda_function_role_name" {
  value = aws_iam_role.lambda_role.name
}
