data "archive_file" "archive-file-snapshot" {
  type        = "zip"
  source_file = "snapshot.py"
  output_path = "snapshot_lambda.zip"
}


resource "aws_lambda_function" "snapshot-lambda-function" {
  function_name = "ebs-poc-snapshot"
  filename      = "snapshot_lambda.zip"
  handler       = "snapshot.lambda_handler"
  runtime       = "python3.8"
  role          = aws_iam_role.snapshot-LambdaRole.arn
  timeout       = "5"
  memory_size   = "128"
  # Terraform was not picking up the changes in the code so did not generate the updated zip file.
  # Resolved from this comment - https://github.com/hashicorp/terraform/issues/8344#issuecomment-265548941
  source_code_hash = data.archive_file.archive-file-snapshot.output_base64sha256
}

# --------------------------------------------------------
# Grant Lmabda Execution Permission to APIG
# --------------------------------------------------------

resource "aws_lambda_permission" "apigw-lambda-permission-snapshot" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.snapshot-lambda-function.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  #source_arn = "arn:aws:execute-api:ap-southeast-2:127632162537:${aws_api_gateway_rest_api.ebs_poc.id}/*/${aws_api_gateway_method.snapshot-api-gateway-method.http_method}${aws_api_gateway_resource.snapshot-api-gateway-resource.path}"
}

# --------------------------------------------------------
# CloudWatch Log Group with 30 Days Retention
# --------------------------------------------------------

resource "aws_cloudwatch_log_group" "snapshot-log-group" {
  name              = "/aws/lambda/${aws_lambda_function.snapshot-lambda-function.function_name}"
  retention_in_days = 7
}


resource "aws_iam_role" "snapshot-LambdaRole" {
  name               = "snapshot-LambdaRole"
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


resource "aws_iam_policy" "snapshot-LambdaPolicy" {
  name        = "RackspaceLambdaPolicySnapshot"
  path        = "/"
  description = "IAM policy for lambda function"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:snapshotLogStream",
          "logs:snapshotLogGroup",
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
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "snapshot-LambdaRolePolicy" {
  role       = aws_iam_role.snapshot-LambdaRole.name
  policy_arn = aws_iam_policy.snapshot-LambdaPolicy.arn
}