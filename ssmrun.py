import json
import boto3
import os
import time
ssm_document_name = os.environ['SSM_DOCUMENT_NAME']

def lambda_handler(event, context):
    print("event => ", event)
    
    volume_id = json.loads(event['body'])['volume_id']
    instance_id = json.loads(event['body'])['instance_id']

    ssm = boto3.client('ssm')
    response = ssm.send_command(    
        InstanceIds=[instance_id],    
        DocumentName=ssm_document_name,    
        Comment='Resize filesystem internally.',     
    )
    print("Sleeping to avoid race condition.")
    time.sleep(3)    

    command_id = response['Command']['CommandId']
    output = ssm.get_command_invocation(
      CommandId=command_id,
      InstanceId=instance_id,
    )

    final_response = {
        'stdout': output['StandardOutputContent'],
        'status': output['Status'],
        'status_details': output['StatusDetails'],
        'stderr': output['StandardErrorContent'],
    }
    
    return {
        'statusCode': 201,
        'body': json.dumps(final_response)
    }