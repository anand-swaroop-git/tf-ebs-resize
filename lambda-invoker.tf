data "archive_file" "archive-file-invoker" {
  type        = "zip"
  source_file = "invoker.py"
  output_path = "invoker_lambda.zip"
}


resource "aws_lambda_function" "invoker-lambda-function" {
  function_name = "state-machine-invoker"
  filename      = "invoker_lambda.zip"
  handler       = "invoker.lambda_handler"
  runtime       = "python3.8"
  role          = aws_iam_role.invoker-LambdaRole.arn
  timeout       = "5"
  memory_size   = "128"
  # Terraform was not picking up the changes in the code so did not generate the updated zip file.
  # Resolved from this comment - https://github.com/hashicorp/terraform/issues/8344#issuecomment-265548941
  source_code_hash = data.archive_file.archive-file-invoker.output_base64sha256
  environment {
    variables = {
      STATE_MACHINE_ARN = aws_sfn_state_machine.sfn_state_machine.arn
    }
  }
}

# --------------------------------------------------------
# Grant Lmabda Execution Permission to APIG
# --------------------------------------------------------

data "aws_caller_identity" "current" {}

resource "aws_lambda_permission" "apigw-lambda-permission-invoker" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.invoker-lambda-function.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.id}:${aws_api_gateway_rest_api.ebs_poc.id}/*/${aws_api_gateway_method.api-gateway-method.http_method}${aws_api_gateway_resource.api-gateway-resource.path}"
}

# --------------------------------------------------------
# CloudWatch Log Group
# --------------------------------------------------------

resource "aws_cloudwatch_log_group" "invoker-log-group" {
  name              = "/aws/lambda/${aws_lambda_function.invoker-lambda-function.function_name}"
  retention_in_days = 7
}


resource "aws_iam_role" "invoker-LambdaRole" {
  name               = "invoker-LambdaRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}


resource "aws_iam_policy" "invoker-LambdaPolicy" {
  name        = "LambdaPolicyinvoker"
  path        = "/"
  description = "IAM policy for lambda function"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:invokerLogStream",
          "logs:invokerLogGroup",
          "logs:PutLogEvents"
        ],
        "Resource" : "arn:aws:logs:*:*:*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:*"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : ["states:StartExecution"],
        "Resource" : ["arn:aws:states:*:*:stateMachine:*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "invoker-LambdaRolePolicy" {
  role       = aws_iam_role.invoker-LambdaRole.name
  policy_arn = aws_iam_policy.invoker-LambdaPolicy.arn
}
