variable "gateway_name" {
  type        = string
  description = "value of the api gateway name"
}

variable "protocol_type" {
  type        = string
  description = "value of the protocol type"
  default     = "HTTP"
}

variable "routes" {
  type        = list(string)
  description = "List of routes to create in the API Gateway"
}

variable "auth0_issuer" {
  type        = string
  description = "Auth0 issuer (e.g., 'your-tenant.auth0.com')"
}

variable "auth0_audience" {
  type        = string
  description = "Auth0 API audience identifier"
}

variable "lambda_invoke_arn" {
  type        = string
  description = "value of the lambda invoke arn"
}

variable "function_name" {
  type        = string
  description = "value of the function name"
}
