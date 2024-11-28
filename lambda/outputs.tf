output "lambda_invoke_arn" {
  value = aws_lambda_function.lambda.invoke_arn
}

output "lambda_function_name" {
  value = aws_lambda_function.lambda.function_name
}

output "lambda_role_arn" {
  value = aws_iam_role.function_role.arn
}
