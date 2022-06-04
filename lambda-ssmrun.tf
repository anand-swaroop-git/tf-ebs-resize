data "archive_file" "archive-file-ssmrun" {
  type        = "zip"
  source_file = "ssmrun.py"
  output_path = "ssmrun_lambda.zip"
}


resource "aws_lambda_function" "ssmrun-lambda-function" {
  function_name = "ssmrun-command"
  filename      = "ssmrun_lambda.zip"
  handler       = "ssmrun.lambda_handler"
  runtime       = "python3.8"
  role          = aws_iam_role.ssmrun-LambdaRole.arn
  timeout       = "5"
  memory_size   = "128"
  # Terraform was not picking up the changes in the code so did not generate the updated zip file.
  # Resolved from this comment - https://github.com/hashicorp/terraform/issues/8344#issuecomment-265548941
  source_code_hash = data.archive_file.archive-file-ssmrun.output_base64sha256
  environment {
    variables = {
      SSM_DOCUMENT_NAME = aws_ssm_document.poc.name
    }
  }
}

# --------------------------------------------------------
# Grant Lmabda Execution Permission to APIG
# --------------------------------------------------------

resource "aws_lambda_permission" "apigw-lambda-permission-ssmrun" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ssmrun-lambda-function.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
}

# --------------------------------------------------------
# CloudWatch Log Group with 30 Days Retention
# --------------------------------------------------------

resource "aws_cloudwatch_log_group" "ssmrun-log-group" {
  name              = "/aws/lambda/${aws_lambda_function.ssmrun-lambda-function.function_name}"
  retention_in_days = 7
}


resource "aws_iam_role" "ssmrun-LambdaRole" {
  name               = "ssmrun-LambdaRole"
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


resource "aws_iam_policy" "ssmrun-LambdaPolicy" {
  name        = "LambdaPolicyssmrun"
  path        = "/"
  description = "IAM policy for lambda function"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:ssmrunLogStream",
          "logs:ssmrunLogGroup",
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
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "ssm:SendCommand",
          "ssm:GetCommandInvocation"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssmrun-LambdaRolePolicy" {
  role       = aws_iam_role.ssmrun-LambdaRole.name
  policy_arn = aws_iam_policy.ssmrun-LambdaPolicy.arn
}
