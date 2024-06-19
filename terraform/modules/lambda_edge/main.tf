provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

resource "aws_iam_role" "lambda_edge" {
  name = "${var.app_name}-lambda-edge-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      },
      {
        Effect = "Allow",
        Principal = {
          Service = "edgelambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_edge_policy" {
  name   = "${var.app_name}-lambda-edge-policy"
  role   = aws_iam_role.lambda_edge.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "lambda:GetFunction",
          "lambda:InvokeFunction"
        ],
        Resource = "*"
      }
    ]
  })
}

# data "archive_file" "lambda_zip" {
#   type        = "zip"
#   source_dir  = "${path.module}/src"
#   output_path = "${path.module}/src/lambda_edge.zip"
# }

resource "aws_lambda_function" "auth0_verifier" {
  provider         = aws.us_east_1
  filename         = "${path.module}/src/lambda_edge.zip"
  function_name    = "${var.app_name}-auth0-verifier"
  role             = aws_iam_role.lambda_edge.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  publish          = true

#   source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  source_code_hash = filebase64sha256("${path.module}/src/lambda_edge.zip")
}

resource "aws_lambda_permission" "allow_cloudfront" {
  provider      = aws.us_east_1
  statement_id  = "AllowExecutionFromCloudFront"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auth0_verifier.function_name
  principal     = "edgelambda.amazonaws.com"
}
