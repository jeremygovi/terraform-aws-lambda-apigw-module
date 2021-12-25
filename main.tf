data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${var.source_path}"
  output_path = "/tmp/lambda_function.zip"
}

resource "aws_lambda_function" "main" {
  function_name = "${var.lambda_function_name}"
  role          = "${aws_iam_role.lambda_basic_role.arn}"
  handler       = "main.handler"
  runtime       = "${var.lambda_runtime}"
  filename      = "/tmp/lambda_function.zip"

  environment {
    variables = "${var.environment_variables}"
  }
}

// lambda role
resource "aws_iam_role" "lambda_basic_role" {
  name = "${var.lambda_function_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

// lambda basic policy
resource "aws_iam_role_policy" "lambda_basic_policy" {
  name = "${var.lambda_function_name}"
  role = "${aws_iam_role.lambda_basic_role.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "lambda:GetAccountSettings"
      ],
      "Resource": [
        "arn:aws:logs:*:*:*"
      ]
    }
  ]
}
EOF
}


// API Gateway

resource "aws_api_gateway_rest_api" "api_gw_rest_api" {
  name        = "${var.api_gateway_name}"
  description = "API Gateway rest api for ${var.api_gateway_name}"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gw_rest_api.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gw_rest_api.root_resource_id}"
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gw_rest_api.id}"
  resource_id   = "${aws_api_gateway_resource.proxy.id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gw_rest_api.id}"
  resource_id = "${aws_api_gateway_method.proxy.resource_id}"
  http_method = "${aws_api_gateway_method.proxy.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.main.invoke_arn}"
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gw_rest_api.id}"
  resource_id   = "${aws_api_gateway_rest_api.api_gw_rest_api.root_resource_id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gw_rest_api.id}"
  resource_id = "${aws_api_gateway_method.proxy_root.resource_id}"
  http_method = "${aws_api_gateway_method.proxy_root.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.main.invoke_arn}"
}

resource "aws_api_gateway_deployment" "api_gw_deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_integration,
    aws_api_gateway_integration.lambda_root_integration,
  ]

  rest_api_id = "${aws_api_gateway_rest_api.api_gw_rest_api.id}"
  stage_name  = "${var.project_name}"
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.main.function_name}"
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.api_gw_rest_api.execution_arn}/*/*"
}


