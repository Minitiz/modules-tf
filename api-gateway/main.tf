locals {}

data "aws_caller_identity" "current_account" {}

data "aws_region" "current_region" {}

resource "aws_apigatewayv2_api" "api" {
  name          = var.gateway_name
  protocol_type = var.protocol_type
}

resource "aws_apigatewayv2_route" "routes" {
  for_each           = toset(var.routes)
  api_id             = aws_apigatewayv2_api.api.id
  route_key          = each.value
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.auth0.id
  target             = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "default"
  auto_deploy = true
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.default.arn
    format          = "{ \"requestId\": \"$context.requestId\", \"ip\": \"$context.identity.sourceIp\", \"caller\": \"$context.identity.caller\", \"user\": \"$context.identity.user\", \"requestTime\": \"$context.requestTime\", \"httpMethod\": \"$context.httpMethod\", \"resourcePath\": \"$context.resourcePath\", \"status\": \"$context.status\", \"protocol\": \"$context.protocol\", \"responseLength\": \"$context.responseLength\" }"
  }
}

resource "aws_cloudwatch_log_group" "default" {
  name              = "/aws/lambda/${var.gateway_name}/default"
  retention_in_days = 14
  kms_key_id        = aws_kms_key.log_group.arn
}

resource "aws_kms_key" "log_group" {
  enable_key_rotation = true
  description         = "KMS key for CloudWatch Log Group encryption"
}

resource "aws_kms_alias" "log_group" {
  name          = "alias/${var.gateway_name}-cloudwatch-log-group"
  target_key_id = aws_kms_key.log_group.id
}

resource "aws_kms_key_policy" "log_group_key_policy" {
  key_id = aws_kms_key.log_group.id
  policy = jsonencode({
    Version = "2008-10-17"
    Id      = "log_group_key_policy"
    Statement = [
      {
        Action = "kms:*"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current_account.account_id}:root"
        }
        Resource = "*"
        Sid      = "Enable IAM User Permissions"
      },
      {
        Effect = "Allow"
        Principal = {
          Service = "logs.${data.aws_region.current_region.name}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_apigatewayv2_authorizer" "auth0" {
  api_id          = aws_apigatewayv2_api.api.id
  authorizer_type = "JWT"
  identity_sources = [
    "$request.header.Authorization"
  ]
  name = "${var.gateway_name}-auth0-authorizer"
  jwt_configuration {
    audience = [var.auth0_audience]
    issuer   = var.auth0_issuer
  }
}

# # Add the integration
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  integration_uri        = var.lambda_invoke_arn
  payload_format_version = "2.0"
}

# Add permission for API Gateway to invoke Lambda
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}
