resource "aws_api_gateway_rest_api" "ebs_poc" {
  name        = "ebs_poc"
  description = "EBS POC API Gateway"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "create-api-gateway-resource" {
  rest_api_id = aws_api_gateway_rest_api.ebs_poc.id
  parent_id   = aws_api_gateway_rest_api.ebs_poc.root_resource_id
  path_part   = "poc"
}

resource "aws_api_gateway_method" "create-api-gateway-method" {
  rest_api_id   = aws_api_gateway_rest_api.ebs_poc.id
  resource_id   = aws_api_gateway_resource.create-api-gateway-resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "createproduct-lambda" {

  rest_api_id = aws_api_gateway_rest_api.ebs_poc.id
  resource_id = aws_api_gateway_method.create-api-gateway-method.resource_id
  http_method = aws_api_gateway_method.create-api-gateway-method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"

  uri = aws_lambda_function.invoker-lambda-function.invoke_arn
}

# Stage 1 Deployment
resource "aws_api_gateway_deployment" "create-api-deployment-stage1" {

  depends_on = [
    aws_api_gateway_integration.createproduct-lambda
  ]

  rest_api_id = aws_api_gateway_rest_api.ebs_poc.id
  stage_name  = "poc"
}