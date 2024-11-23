
locals {}

resource "aws_apigatewayv2_api" "api" {
  name          = var.gateway_name
  protocol_type = var.protocol_type
}

resource "aws_apigatewayv2_route" "test_route" {
  for_each           = { for route in var.routes : route.route_key => route }
  api_id             = aws_apigatewayv2_api.api.id
  route_key          = each.value.route_key
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.auth0.id
  target             = each.value.target
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "default"
  auto_deploy = true
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
