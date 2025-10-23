resource "aws_s3_bucket" "image_bucket" {
  bucket = var.s3_image_bucket_name
}

resource "aws_s3_bucket_cors_configuration" "image_bucket_cors" {
  bucket = aws_s3_bucket.image_bucket.id
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST"]
    allowed_origins = ["*"]
  }
}

resource "aws_lambda_function" "upload_url_lambda" {
  function_name    = "get-upload-url"
  filename         = "../upload_lambda.zip"
  source_code_hash = ("../upload/upload_lambda.zip")
  handler          = "upload_url.lambda_handler"
  runtime          = "python3.10"
  role             = data.aws_iam_role.lab_role.arn
  timeout          = 60
}

resource "aws_lambda_function" "analyze_lambda" {
  function_name    = "analyze-image"
  filename         = "../analyze_lambda.zip"
  source_code_hash = ("../upload/analyze_lambda.zip")
  handler          = "analyze.lambda_handler"
  runtime          = "python3.10"
  role             = data.aws_iam_role.lab_role.arn
  timeout          = 60
}

resource "aws_api_gateway_rest_api" "api" {
  name        = "AI-Analyzer-API"
  description = "API to APP Rekognition"
}

resource "aws_api_gateway_resource" "upload" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "upload-url"
}


resource "aws_api_gateway_method" "upload_post" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.upload.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "upload_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.upload.id
  http_method             = aws_api_gateway_method.upload_post.http_method
  integration_http_method = "AWS_PROXY"
  type                    = "POST"
  uri                     = aws_lambda_function.upload_url_lambda.invoke_arn
}

resource "aws_api_gateway_resource" "analyze" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "analyze"
}

resource "aws_api_gateway_method" "analyze_post" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.analyze.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "analyze_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.analyze.id
  http_method             = aws_api_gateway_method.analyze_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.analyze_lambda.invoke_arn
}

module "cors_upload" {
  source          = "squidfunk/api-gateway-enable-cors/aws"
  version         = "0.3.3"
  api_id          = aws_api_gateway_rest_api.api.id
  api_resource_id = aws_api_gateway_resource.upload.id
}

module "cors_analyze" {
  source          = "squidfunk/api-gateway-enable-cors/aws"
  version         = "0.3.3"
  api_id          = aws_api_gateway_rest_api.api.id
  api_resource_id = aws_api_gateway_resource.analyze.id
}

resource "aws_lambda_permission" "allow_api_upload" {
  statement_id  = "AllowAPIGatewayInvokeUpload"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.upload_url_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "allow_api_analyze" {
  statement_id  = "AllowAPIGatewayInvokeAnalyze"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.analyze_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  # Truco para forzar un nuevo despliegue cuando algo cambia
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.upload.id,
      aws_api_gateway_resource.analyze.id,
      module.cors_upload.id,
      module.cors_analyze.id
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "prod"
}