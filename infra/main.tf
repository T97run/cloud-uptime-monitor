########################
# Random suffix for unique names
########################
resource "random_id" "suffix" {
  byte_length = 4
}

########################
# S3 bucket for status.json (private, versioned)
########################
resource "aws_s3_bucket" "data" {
  bucket = "${var.project_name}-data-${random_id.suffix.hex}"
}

resource "aws_s3_bucket_versioning" "data" {
  bucket = aws_s3_bucket.data.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_public_access_block" "data" {
  bucket                  = aws_s3_bucket.data.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

########################
# IAM trust policy for Lambda
########################
data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

########################
# Pinger role & inline policy (Put to status.json + logs)
########################
resource "aws_iam_role" "pinger" {
  name               = "${var.project_name}-pinger-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

data "aws_iam_policy_document" "pinger" {
  statement {
    sid     = "AllowWriteStatus"
    actions = ["s3:PutObject"]
    resources = [
      "${aws_s3_bucket.data.arn}/status.json"
    ]
  }
  statement {
    sid = "Logs"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "pinger" {
  name   = "${var.project_name}-pinger-inline"
  role   = aws_iam_role.pinger.id
  policy = data.aws_iam_policy_document.pinger.json
}

########################
# Reader role & inline policy (Get that object + logs)
########################
resource "aws_iam_role" "reader" {
  name               = "${var.project_name}-reader-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

data "aws_iam_policy_document" "reader" {
  statement {
    sid     = "AllowReadStatus"
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.data.arn}/status.json"
    ]
  }
  statement {
    sid = "Logs"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "reader" {
  name   = "${var.project_name}-reader-inline"
  role   = aws_iam_role.reader.id
  policy = data.aws_iam_policy_document.reader.json
}

########################
# Lambda: Pinger (writes status.json)
########################
resource "aws_lambda_function" "pinger" {
  function_name    = "${var.project_name}-pinger"
  role             = aws_iam_role.pinger.arn
  runtime          = var.runtime
  handler          = "app.handler"
  memory_size      = var.memory_mb
  timeout          = var.timeout_seconds
  filename         = "${path.module}/pinger.zip"
  source_code_hash = filebase64sha256("${path.module}/pinger.zip")

  environment {
    variables = {
      DATA_BUCKET = aws_s3_bucket.data.bucket
      URLS        = join(",", var.urls)
    }
  }
}

########################
# EventBridge schedule → Pinger
########################
resource "aws_cloudwatch_event_rule" "schedule" {
  name                = "${var.project_name}-schedule"
  schedule_expression = var.schedule_expression
}

resource "aws_cloudwatch_event_target" "pinger" {
  rule      = aws_cloudwatch_event_rule.schedule.name
  target_id = "pinger"
  arn       = aws_lambda_function.pinger.arn
}

resource "aws_lambda_permission" "allow_events" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pinger.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule.arn
}

########################
# Lambda: Reader (reads status.json)
########################
resource "aws_lambda_function" "reader" {
  function_name    = "${var.project_name}-reader"
  role             = aws_iam_role.reader.arn
  runtime          = var.runtime
  handler          = "app.handler"
  memory_size      = var.memory_mb
  timeout          = var.timeout_seconds
  filename         = "${path.module}/reader.zip"
  source_code_hash = filebase64sha256("${path.module}/reader.zip")

  environment {
    variables = {
      DATA_BUCKET = aws_s3_bucket.data.bucket
    }
  }
}

########################
# HTTP API (v2) + Lambda proxy
########################
resource "aws_apigatewayv2_api" "http" {
  name          = "${var.project_name}-api"
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "OPTIONS"]
    allow_headers = ["*"]
  }
}

resource "aws_apigatewayv2_integration" "reader" {
  api_id                 = aws_apigatewayv2_api.http.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.reader.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "status" {
  api_id    = aws_apigatewayv2_api.http.id
  route_key = "GET /status"
  target    = "integrations/${aws_apigatewayv2_integration.reader.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.reader.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http.execution_arn}/*/*"
}
