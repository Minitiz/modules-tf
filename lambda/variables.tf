variable "lambda_name" {
  description = "The name of the Lambda function"
  type        = string
}

variable "lambda_runtime" {
  description = "The runtime of the Lambda function"
  type        = string
}

variable "lambda_architectures" {
  description = "The architectures of the Lambda function"
  type        = list(string)
}

variable "source_file" {
  description = "The source file of the Lambda function"
  type        = string
}

variable "output_path" {
  description = "The output path of the Lambda function"
  type        = string
}
