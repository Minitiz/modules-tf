locals {}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = var.source_file
  output_path = var.output_path
}

data "aws_caller_identity" "current_account" {}
data "aws_region" "current_region" {}
data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
    ]
  }
}

resource "random_string" "random" {
  length  = 4
  special = false
}

resource "aws_lambda_function" "lambda" {
  function_name    = "${var.lambda_name}-${random_string.random.id}"
  role             = aws_iam_role.function_role.arn
  handler          = "bootstrap"
  runtime          = var.lambda_runtime
  architectures    = var.lambda_architectures
  filename         = var.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256
  tracing_config {
    mode = "Active"
  }
}


resource "aws_iam_role" "function_role" {
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}
resource "aws_iam_role_policy" "lambda_basic_execution" {
  name = "AWSLambdaBasicExecutionRole"
  role = aws_iam_role.function_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_kms_key" "log_group_key" {}

resource "aws_kms_key_policy" "log_group_key_policy" {
  key_id = aws_kms_key.log_group_key.id
  policy = jsonencode({
    Id = "log_group_key_policy"
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
        Effect = "Allow",
        Principal = {
          Service : "logs.${data.aws_region.current_region.name}.amazonaws.com"
        },
        Action = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ],
        Resource = "*"
      }
    ]
    Version = "2012-10-17"
  })
}



# Explicitly create the function’s log group to set retention and allow auto-cleanup
resource "aws_cloudwatch_log_group" "lambda_function_log" {
  retention_in_days = 1
  name              = "/aws/lambda/${aws_lambda_function.lambda.function_name}"
  kms_key_id        = aws_kms_key.log_group_key.arn
}
