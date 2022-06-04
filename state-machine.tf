resource "aws_sfn_state_machine" "sfn_state_machine" {
  name     = "ebs-resize-state-machine"
  role_arn = aws_iam_role.iam_for_sfn.arn
  # TODO: Remove inline json and use templating
  definition = <<EOF
{
  "Comment": "A description of my state machine",
  "StartAt": "GetVolumeID",
  "States": {
    "GetVolumeID": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "OutputPath": "$.Payload",
      "Parameters": {
        "Payload.$": "$",
        "FunctionName": "${aws_lambda_function.volumeid-lambda-function.arn}:$LATEST"
      },
      "Retry": [
        {
          "ErrorEquals": [
            "Lambda.ServiceException",
            "Lambda.AWSLambdaException",
            "Lambda.SdkClientException"
          ],
          "IntervalSeconds": 2,
          "MaxAttempts": 6,
          "BackoffRate": 2
        }
      ],
      "Next": "TakeSnapshot"
    },
    "TakeSnapshot": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "OutputPath": "$.Payload",
      "Parameters": {
        "Payload.$": "$",
        "FunctionName": "${aws_lambda_function.snapshot-lambda-function.arn}:$LATEST"
      },
      "Retry": [
        {
          "ErrorEquals": [
            "Lambda.ServiceException",
            "Lambda.AWSLambdaException",
            "Lambda.SdkClientException"
          ],
          "IntervalSeconds": 2,
          "MaxAttempts": 6,
          "BackoffRate": 2
        }
      ],
      "Next": "WaitForSnapshot"
    },
    "WaitForSnapshot": {
      "Type": "Wait",
      "Seconds": 120,
      "Next": "ModifyEBS"
    },
    "ModifyEBS": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "OutputPath": "$.Payload",
      "Parameters": {
        "Payload.$": "$",
        "FunctionName": "${aws_lambda_function.modifyebs-lambda-function.arn}:$LATEST"
      },
      "Retry": [
        {
          "ErrorEquals": [
            "Lambda.ServiceException",
            "Lambda.AWSLambdaException",
            "Lambda.SdkClientException"
          ],
          "IntervalSeconds": 2,
          "MaxAttempts": 6,
          "BackoffRate": 2
        }
      ],
      "Next": "WaitForEBSModification"
    },
    "WaitForEBSModification": {
      "Type": "Wait",
      "Seconds": 60,
      "Next": "ResizeFileSystem"
    },
    "ResizeFileSystem": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "OutputPath": "$.Payload",
      "Parameters": {
        "Payload.$": "$",
        "FunctionName": "${aws_lambda_function.ssmrun-lambda-function.arn}:$LATEST"
      },
      "Retry": [
        {
          "ErrorEquals": [
            "Lambda.ServiceException",
            "Lambda.AWSLambdaException",
            "Lambda.SdkClientException"
          ],
          "IntervalSeconds": 2,
          "MaxAttempts": 6,
          "BackoffRate": 2
        }
      ],
      "End": true
    }
  }
}
EOF
}

resource "aws_iam_role" "iam_for_sfn" {
  name               = "statemachinefunctionrole"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "states.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF

}


resource "aws_iam_policy" "statemachine-policy" {
  name        = "Statemachinepolicy"
  path        = "/"
  description = "IAM policy for lambda function"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "lambda:InvokeFunction"
        ],
        "Resource" : [
          "${aws_lambda_function.volumeid-lambda-function.arn}:*",
          "${aws_lambda_function.snapshot-lambda-function.arn}:*",
          "${aws_lambda_function.modifyebs-lambda-function.arn}:*",
          "${aws_lambda_function.ssmrun-lambda-function.arn}:*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "lambda:InvokeFunction"
        ],
        "Resource" : [
          "${aws_lambda_function.volumeid-lambda-function.arn}",
          "${aws_lambda_function.snapshot-lambda-function.arn}",
          "${aws_lambda_function.modifyebs-lambda-function.arn}",
          "${aws_lambda_function.ssmrun-lambda-function.arn}"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords",
          "xray:GetSamplingRules",
          "xray:GetSamplingTargets"
        ],
        "Resource" : [
          "*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "state-machine" {
  role       = aws_iam_role.iam_for_sfn.name
  policy_arn = aws_iam_policy.statemachine-policy.arn
}
