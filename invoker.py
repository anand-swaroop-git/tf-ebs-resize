import json
import boto3
import datetime
import os

state_machine_arn = os.environ['STATE_MACHINE_ARN']
def lambda_handler(event, context):
    payload = json.loads(event['body'])
    instance_id = payload['instance_id']
    
    sf = boto3.client('stepfunctions')

    input_to_statemachine = {
            'instance_id': instance_id,
    }

    execution_id = 'ebs-expansion' + datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")

    sf.start_execution(    
    stateMachineArn = state_machine_arn,    
    name = execution_id,    
    input = json.dumps(input_to_statemachine)
    )   

    return {
        'statusCode': 201,
        'body': json.dumps({
            'instance_id': instance_id,
            'status': 'Passing on the instance id from APIG'
        })
    }